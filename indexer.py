import codecs
import logging
import shlex
import threading
import time
from datetime import datetime, timedelta
from decimal import Decimal, getcontext
from timeit import default_timer as timer

from sqlalchemy.exc import IntegrityError
from web3.constants import ADDRESS_ZERO
from web3.exceptions import ContractLogicError

import sentry
import settings
from models import (
    Airdrop,
    Claim,
    ClaimStatus,
    FundraisePositions,
    IndexerState,
    Protocol,
    ProtocolCoverage,
    ProtocolNonstakers,
    ProtocolPremium,
    Session,
    StakingPositions,
    StakingPositionsMeta,
    StatsAPY,
    StatsExternalCoverage,
    StatsTVC,
    StatsTVL,
    StrategyBalance,
)
from models.interval_function import IntervalFunction
from strategies.custom_yields import CUSTOM_YIELDS, MapleYield
from strategies.strategies import Strategies
from utils import (
    get_block_timestamp,
    get_core_contract_token_values,
    get_event_logs_in_range,
    get_premiums_apy,
    time_delta_apy,
)

YEAR = Decimal(timedelta(days=365).total_seconds())
getcontext().prec = 78

logger = logging.getLogger(__name__)


class Indexer:
    def __init__(self):
        """Mapping between contract events and indexing functions.

        The order is important, because some events may be emitted in bulk, in the same block.

        For example, when adding a new protocol, the ProtocolAgentTransfer event is emitted before ProtocolAdded.
        In this case, we need to first process the ProtocolAdded event, to save the newly added protocol,
        and then process ProtocolAgentTransfer, in order to change that protocol's agent address.

        Another example would be on protocol removal, when ProtocolPremiumChanged, ProtocolAgentTransfer,
        ProtocolUpdated and ProtocolRemoved events are all emitted in the same block.
        Currently, this case does not pose an issue, but in the case we will ever delete the protocol
        from the database, on ProtocolRemoved event, we must make sure that event is indexed last,
        so the other event handlers will still have access to the corresponding protocol instance.

        Note: As all contract events are processed in a single database transaction per block,
        it doesn't cause any unexpected data mutations during the processing.
        """
        self.events = {
            settings.CORE_WSS.events.Transfer: self.Transfer.new,
            settings.CORE_WSS.events.Restaked: self.Restaked.new,
            settings.CORE_WSS.events.ArbRestaked: self.Restaked.new,
            settings.SHER_BUY_WSS.events.Purchase: self.Purchase.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolRemoved: self.ProtocolRemoved.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolRemovedByArb: self.ProtocolRemoved.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolAdded: self.ProtocolAdded.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolAgentTransfer: self.ProtocolAgentTransfer.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolUpdated: self.ProtocolUpdated.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolPremiumChanged: self.ProtocolPremiumChanged.new,
            settings.SHERLOCK_CLAIM_MANAGER_WSS.events.ClaimCreated: self.ClaimCreated.new,
            settings.SHERLOCK_CLAIM_MANAGER_WSS.events.ClaimStatusChanged: self.ClaimStatusChanged.new,
            settings.SHERLOCK_CLAIM_MANAGER_WSS.events.ClaimPayout: self.ClaimPayout.new,
            settings.SHER_CLAIM_WSS.events.Claim: self.FundraiseClaimed.new,
        }

        for distributor in settings.MERKLE_DISTRIBUTORS_WSS:
            self.events[distributor.events.Claimed] = self.AirdropClaimed.new

        # Order is important, because some functions might depends on the result of the previous ones.
        # - `index_apy` must have an up to date APY computed, so it must come after `calc_apy`
        # -- NOTE: `calc_apy` can fail to store an up to date APY under specific conditions,
        #          this would cause `index_apy` to use an old value.
        # - `calc_additional_apy` must have TVL computed, so it must come after `calc_tvl`
        self.intervals = {
            self.calc_tvl: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.calc_tvc: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.calc_apy: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.calc_additional_apy: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.index_apy: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.reset_balance_factor: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.index_strategy_balances: settings.INDEXER_STATS_BLOCKS_PER_CALL,
        }

    def calc_balance_factor(self, session, indx, block, timestamp):
        """
        Compute the balance factor (the balance increase since the last computation)
        by comparing a staking position's balance at two different moments in time.

        Args:
            session: DB session
            indx: Indexer state
            block: Current block number
        """
        logger.info("Computing balance factor")

        # Skip computation if meta has not been initialised yet
        # (we do not have a reference point in time - a T0).
        # Meta is initialised either on the first indexed staking event,
        # or on the first tick of `reset_balance_factor`.
        meta = StakingPositionsMeta.get(session)
        if meta.usdc_last_updated == datetime.min:
            logger.info("Meta not yet initialised. Returning...")
            return

        # Compute the time delta between current block's timestamp
        # and the last time the balance have been updated.
        # Skip computation if no time has passed.
        position_timedelta = timestamp - meta.usdc_last_updated.timestamp()
        if position_timedelta == 0:
            logger.info("No time has passed since last computation. Returning...")
            return

        # Fetch an active staking position
        positions = session.query(StakingPositions).order_by(StakingPositions.usdc.desc()).all()
        if len(positions) == 0:
            logger.info("No staking positions")

        safe_time = datetime.fromtimestamp(timestamp) + timedelta(days=7)
        for position in positions:
            # Look for a position that is not going to expire soon
            if position.lockup_end < safe_time:
                continue

            try:
                # Fetch current position balance as well as
                # the increase since the last computation (a.k.a the balance factor)
                _, factor = position.get_balance_data(block)
                logger.info("Computed a balance factor of %s", factor)

                # Save the computation by updating the indexer state
                indx.balance_factor = factor
                indx.last_time = datetime.fromtimestamp(timestamp)

                # Return after successfully calculating the balance factor
                return
            except Exception as e:
                logger.exception(e)

        logger.info("Could not calculate balance factor for any existing staking positions")

    def index_apy(self, session, indx, block, timestamp):
        """Index current total APY and premiums APY.

        Args:
            session: DB session
            indx: Indexer state
            block: Current block
        """
        apy = Decimal(indx.apy) + Decimal(indx.additional_apy)
        premiums_apy = indx.premiums_apy
        incentives_apy = indx.incentives_apy

        StatsAPY.insert(session, block, timestamp, apy, premiums_apy, incentives_apy)

    def calc_tvl(self, session, indx, block, timestamp):
        logger.info(f"Calculating TVL at block {block}")
        tvl = settings.CORE_WSS.functions.totalTokenBalanceStakers().call(block_identifier=block)

        StatsTVL.insert(session, block, timestamp, tvl)

    def calc_tvc(self, session, indx, block, timestamp):
        accumulated_tvc_for_block = Decimal("0")
        accumulated_external_coverage_for_block = Decimal("0")

        now = datetime.fromtimestamp(timestamp)
        try:
            for row in settings.PROTOCOLS_CSV:
                if "id" not in row:
                    continue
                if not row["premium_float"]:
                    continue

                protocol_id = row["id"]
                protocol = Protocol.get(session, protocol_id)
                # Given that our datasource is the spreadsheet, the protocol could not be present in the DB yet
                if not protocol:
                    continue

                try:
                    premium_amount = settings.SHERLOCK_PROTOCOL_MANAGER_WSS.functions.premium(
                        protocol.bytes_identifier
                    ).call(block_identifier=block)
                except ContractLogicError:
                    continue

                # Compute protocol TVL
                protocol_tvl = int(premium_amount * float(YEAR) / row["premium_float"])
                # Round to nearest amount by $5k TVL
                protocol_tvl = round(protocol_tvl, -9)
                logger.info(f"{row['name']} TVL is: {protocol_tvl:,}")
                protocol.tvl = protocol_tvl

                accumulated_tvc_for_block += protocol_tvl

                # Compute protocol external coverage
                external_coverage = Decimal("0")
                if now < settings.HARDCODED_PROTOCOL_EXTERNAL_COVERAGE_END_DATE:
                    if protocol_id in settings.HARDCODED_PROTOCOL_EXTERNAL_COVERAGE:
                        # Use hardcoded protocol external coverage value
                        for start_date, amount in settings.HARDCODED_PROTOCOL_EXTERNAL_COVERAGE[protocol_id].items():
                            if now >= start_date:
                                external_coverage = Decimal(amount) * Decimal("1000000")
                else:
                    # Compute external coverage value based on on-chain values
                    nonstakers_fee = protocol.current_nonstakers.nonstakers / Decimal(1e18)
                    sherlock_fee = Decimal("0.1")
                    nexus_share = (nonstakers_fee - sherlock_fee) / Decimal("0.9")
                    external_coverage = max(Decimal("0"), protocol_tvl * nexus_share)

                logger.info(f"{row['name']} External Coverage is: {external_coverage:,}")
                accumulated_external_coverage_for_block += external_coverage

            if now < settings.HARDCODED_TOTAL_EXTERNAL_COVERAGE_END_DATE:
                # Use hardcoded total external coverage value
                for start_date, amount in settings.HARDCODED_TOTAL_EXTERNAL_COVERAGE.items():
                    if now >= start_date:
                        accumulated_external_coverage_for_block = Decimal(amount) * Decimal("1000000")

            StatsTVC.insert(session, block, timestamp, accumulated_tvc_for_block)
            StatsExternalCoverage.insert(session, block, timestamp, accumulated_external_coverage_for_block)
        except Exception as e:
            logger.exception("TVC calc encountered exception %s" % e)

    def calc_apy(self, session, indx, block, current_timestamp):
        """Compute the total APY and the premiums APY;

        The total APY is computed using the delta of a staking position's balance.

        Args:
            session (State): DB session
            indx (IndexerState): Indexer state
            block (int): Current block
        """
        # FIXME: Situation where there are no staking positions but there is APY coming from protocols
        # Fetch the oldest active staking position
        position = StakingPositions.get_oldest_position(session)
        if not position:
            return

        logger.info("Calculating APY")
        logger.info(f"Current block {block}")
        previous_block = block - settings.INDEXER_STATS_BLOCKS_PER_CALL
        logger.info(f"Previous block {previous_block}")

        if previous_block < settings.INDEXER_START_BLOCK:
            logger.info("Too soon to calculate APY. Skipping...")
            return

        try:
            token_values = get_core_contract_token_values(block=block, token_id=position.id)
            current_balance = int(token_values["usdc"])
        except Exception as e:
            logger.exception(e)
            logger.debug("Could not fetch current balance. The position is too fresh for the current block")
            return

        try:
            prev_token_values = get_core_contract_token_values(block=previous_block, token_id=position.id)
            previous_balance = int(prev_token_values["usdc"])
        except Exception as e:
            logger.exception(e)
            logger.debug(
                "Could not fetch previous balance. 24 hours must have passed since the oldest staking position was created."  # noqa
            )
            return

        # Compute the APY using the delta between the staking position's balances
        previous_timestamp = get_block_timestamp(previous_block)
        apy = time_delta_apy(previous_balance, current_balance, current_timestamp - previous_timestamp)
        logger.info("Computed an APY of %s", apy)

        # Update APY only if relevant, that means skip negative APYs generated by payouts
        # Position balances are still being correctly kept up to date
        # using the balance factor which accounts for payouts.
        if apy < 0:
            logger.warning("APY %s is being skipped because is negative." % apy)
            sentry.report_message(
                "APY is being skipped because it is negative!",
                "warning",
                {"current_apy": float(apy * 100)},
            )
            return

        indx.apy = apy

        # Compute the APY coming from protocol premiums
        tvl = StatsTVL.get_current_tvl(session)
        if not tvl:
            return

        premiums_per_second = ProtocolPremium.get_stakers_share_of_premiums(session)
        print("Stakers share of premiums per second", premiums_per_second)
        incentives_per_second = ProtocolPremium.get_usdc_incentive_premiums(session)

        # Incentives are included in the total premiums, exclude them here
        if premiums_per_second is not None and incentives_per_second is not None:
            premiums_per_second -= incentives_per_second

        premiums_apy = get_premiums_apy(tvl.value, premiums_per_second) if premiums_per_second else 0
        logger.info("Computed a Premiums APY of %s", premiums_apy)

        incentives_apy = get_premiums_apy(tvl.value, incentives_per_second) if incentives_per_second else 0
        logger.info("Computed an Incentives APY of %s", incentives_apy)

        # When an increase in a protocol's premium takes place, and the TVL has not increased yet proportionally,
        # the premiums APY will be higher than the total APY.
        # We skip updating the premium until the next interval and wait for the TVL to increase.
        if premiums_apy > indx.apy:
            logger.warning("Premiums APY %s is being clamped because it is higher than the total APY." % premiums_apy)
            premiums_apy = indx.apy

        indx.premiums_apy = premiums_apy

        if incentives_apy > indx.apy:
            logger.warning(
                "Incentive APY %s is being skipped beacuse it is higher than the total APY." % incentives_apy
            )
        else:
            indx.incentives_apy = incentives_apy

    def reset_balance_factor(self, session, indx, block, timestamp):
        """Update staking positions' balances to become up to date
        and reflect the real-time data from the contract, without
        actually interacting with the blockchain for each position.

        It is possible by using `calc_factors` to compute the increase of
        a position's balance over time (balance factor), applying the same increase
        to all active staking positions then resetting the balance factor to 1.

        A balance factor of 1 means the positions are up to date.

        Before updating the balances, if possible, this method will try to
        compute the latest balance factor before doing any work.

        Note: This method must initially be executed at least once,
        before any computation can be made, in order to set an
        initial point in time for the balance factor (a T0).

        Args:
            session: DB session
            indx: Indexer state
            block: Current block number
        """

        # Compute the balance factor only if there is a staking position available
        self.calc_balance_factor(session, indx, block, timestamp)

        # Update all staking positions with current factor
        StakingPositionsMeta.update(session, block, indx.balance_factor)

        # Reset factor
        indx.balance_factor = Decimal(1)

    def index_strategy_balances(self, session, indx, block, timestamp):
        """Index each strategy's current balances.

        Args:
            session: DB session
            indx: Indexer state
            block: Block number
        """
        for strategy in Strategies.ALL:
            balance = strategy.get_balance(block)

            if balance is not None:
                # If strategy is deployed and active
                StrategyBalance.insert(session, block, timestamp, strategy.address, balance)

    def calc_additional_apy(self, session, indx, block, timestamp):
        """Compute the additionl APY coming from custom yield strtegies.
        (e.g. Maple, TrueFi)

        Args:
            session: DB session
            indx: Indexer state
            block: Block number
        """
        additional_apy = 0.0
        for custom_yield in CUSTOM_YIELDS:
            apy = custom_yield.get_apy(block, timestamp)
            balance = custom_yield.strategy.get_balance(block)

            logger.info("Strategy %s has balance %s and APY %s" % (custom_yield.strategy, balance, apy))

            # If strategy is deployed and active and the APY has been successfully fetched
            if balance is not None and apy is not None:
                tvl = session.query(StatsTVL).order_by(StatsTVL.timestamp.desc()).first()

                logger.info("Balance is %s and TVL value is %s" % (balance, str(tvl.value)))

                # Compute the additional APY generated by this strategy by multipliying the
                # computed APY with the weights of this strategy in the entire TVL
                strategy_weight = balance / (tvl.value)
                logger.info("Strategy weight %s" % strategy_weight)
                weighted_apy = float(strategy_weight) * apy
                logger.info("Weghted APY %s" % weighted_apy)

                additional_apy += weighted_apy

        logger.info("Computed additional APY of %s" % additional_apy)
        indx.additional_apy = additional_apy

    def log_maple_apy(self, session, indx, block, timestamp):
        """Log Maple APY to a file in order to save historical data.

        Args:
            session: DB session
            indx: Indexer state
            block: Block number
        """
        logger.info("Saving historical Maple APY")

        apy = MapleYield(Strategies.MAPLE).get_apy(block, timestamp, log=True)
        if apy is None:
            return
        logger.info("Maple APY: %s" % apy)

        with open(settings.MAPLE_APY_HISTORY_CSV_NAME, "a") as f:
            f.write(f"{block},{timestamp},{apy}\n")

    class Transfer:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            if args["to"] == ADDRESS_ZERO:
                StakingPositions.delete(session, args["tokenId"])
                return
            elif args["from"] != ADDRESS_ZERO:
                # from and to both are not zero, this is an actual transfer
                StakingPositions.update(
                    session,
                    args["tokenId"],
                    args["to"],
                )
                return

            # Update all database entries to be up to date with block
            self.reset_balance_factor(session, indx, block, timestamp)

            # Insert will retrieve active information (usdc, sher, lockup)
            StakingPositions.insert(
                session,
                block,
                args["tokenId"],
                args["to"],
            )

    class Purchase:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            position = FundraisePositions.get(session, args["buyer"])
            if position is None:
                FundraisePositions.insert(
                    session,
                    block,
                    args["buyer"],
                    args["staked"],
                    args["paid"],
                    args["amount"],
                )
            else:
                position.stake += args["staked"]
                position.contribution += args["paid"]
                position.reward += args["amount"]

    class ProtocolAdded:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])

            Protocol.insert(session, protocol_bytes_id)

    class ProtocolAgentTransfer:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            new_agent = args["to"]

            Protocol.update_agent(session, protocol_bytes_id, new_agent)

    class ProtocolPremiumChanged:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            new_premium = args["newPremium"]

            protocol = Protocol.get(session, protocol_bytes_id)
            if not protocol:
                return

            ProtocolPremium.insert(session, protocol.id, new_premium, timestamp)

    class ProtocolRemoved:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])

            Protocol.remove(session, protocol_bytes_id, timestamp)

    class Restaked:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            token_id = args["tokenID"]

            # Update all database entries to be up to date with block
            self.reset_balance_factor(session, indx, block, timestamp)

            # Restake position
            StakingPositions.restake(session, block, token_id)

    class ProtocolUpdated:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            coverage_amount = args["coverageAmount"]
            nonstakers = args["nonStakers"]

            protocol = Protocol.get(session, protocol_bytes_id)
            if not protocol:
                return

            ProtocolCoverage.update(session, protocol.id, coverage_amount, timestamp)
            ProtocolNonstakers.insert(session, protocol.id, nonstakers, timestamp)

            # Coverages are updated, make new TVC calculation
            self.calc_tvc(session, indx, block)

    class ClaimCreated:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            protocol = Protocol.get(session, protocol_bytes_id)

            if not protocol:
                return

            (
                created,
                _,
                initiator,
                _,
                _,
                receiver,
                exploit_started_at,
                _,
                ancillary_data,
            ) = settings.SHERLOCK_CLAIM_MANAGER_WSS.functions.claim(args["claimID"]).call(block_identifier=block)

            lexer = shlex.shlex(codecs.decode(ancillary_data, "UTF-8"), posix=True)
            lexer.whitespace_split = True
            lexer.whitespace = ","
            ancillary_data_dict = dict(pair.split(":", 1) for pair in lexer)

            Claim.insert(
                session,
                args["claimID"],
                protocol.id,
                initiator,
                receiver,
                args["amount"],
                ancillary_data_dict.get("Resources"),
                exploit_started_at,
                created,
            )

    class ClaimStatusChanged:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            claim_id = args["claimID"]
            new_status = args["currentState"]

            if new_status == 0:
                logger.info("Claim status is NonExistent. Won't index it.")
                return

            ClaimStatus.insert(session, claim_id, new_status, tx_hash, timestamp)

    class ClaimPayout:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            claim_id = args["claimID"]

            ClaimStatus.insert(session, claim_id, ClaimStatus.Status.PaidOut.value, tx_hash, timestamp)

    class AirdropClaimed:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            index = args["index"]
            account = args["account"]

            Airdrop.mark_claimed(session, index, account, contract_address, block, timestamp)

    class FundraiseClaimed:
        def new(self, session, indx, block, timestamp, tx_hash, args, contract_address):
            account = args["account"]

            FundraisePositions.mark_as_claimed(session, account, timestamp)

    def start(self):
        # get last block indexed from database
        with Session() as s:
            start_block = s.query(IndexerState).first().last_block
            logger.info("Starting indexer loop from block %s", start_block)

        t = threading.currentThread()
        logger.info("Thread started")

        while getattr(t, "do_run", True):
            try:
                s = Session()

                # We try to stay behind the blockchain by 1 block,
                # in order to account for 1 block deep reorgs.
                # An example of a potential issue generated by a reorg:
                #
                # Main chain (A): Blocks 100 -> 101
                # > Alice stakes and the tx gets mined on block 101
                # > We are indexing the latest block, and we include Alice's transaction
                #
                # Forked chain (B): Blocks 100 -> 101
                # > Bob stakes and tx gets mined on block 101, but on the chain B
                # > We are not indexing this block, since we are watching the other chain
                #
                # Block 102 gets mined on the forked chain B
                # > A reorg happens and chain B becomes the main chain
                #
                #    Indexer is here ↓
                #                -> 101 (Chain A - fork)
                #              /
                # Blocks 100 -> 101 -> 102 (Chain B - main)
                #                        ↑
                # Indexer will continue here, which means block 101 from chain B gets skipped,
                # and Bob's staking position does not get indexed.
                current_block = settings.WEB3_WSS.eth.blockNumber - 1
                # We still run 2000 blocks at a time to ensure we save the progress
                # TODO: Remove this after we find a way for the reindex to be instant
                end_block = start_block + 100_000

                if end_block >= current_block:
                    end_block = current_block

                if start_block > end_block:
                    logger.info(
                        "Block %s not yet mined. Last block %s. Sleeping for %ss.",
                        start_block,
                        end_block,
                        settings.INDEXER_SLEEP_BETWEEN_CALL,
                    )
                    time.sleep(settings.INDEXER_SLEEP_BETWEEN_CALL)
                    continue

                # Explicitly lock table
                # Will make any other thread wait that tries to acquire the state
                # Will be released on `commit`
                # Will wait for lock to be released in case it's acquired
                s.execute("select pg_advisory_xact_lock(1)")
                # If think update apy factor here? So we can already use in the events
                indx = s.query(IndexerState).first()

                # self.index_events_time needs to be executed first.
                # The Transfer updates meta.usdc_last_updated on line with StakingPositionsMeta.update.
                # This variable is again uses in calc_factors with
                # position_timedelta = timestamp - meta.usdc_last_updated.timestamp()
                self.index_events_time(s, indx, start_block, end_block)
                self.index_intervals(s, indx, end_block)

                start_block = end_block + 1
                indx.last_block = start_block
                s.commit()
            except Exception as e:
                logger.exception(e)
                time.sleep(settings.INDEXER_SLEEP_BETWEEN_CALL)
            finally:
                # Return connection to the connection pool
                s.close()

    def index_intervals(self, session, indx, block, force=False):
        logger.info("Running interval indexing functions")
        for func, interval in self.intervals.items():
            # Check if the interval function must run
            interval_function = IntervalFunction.get(session, func.__name__)
            function_last_run = interval_function.block_last_run or settings.INDEXER_START_BLOCK - 1
            if block <= function_last_run:
                # Can only be thrown when forcing intervals with custom block
                raise RuntimeError("Can not run interval function in the past")
            if block < function_last_run + interval and not force:
                logger.info("Too soon to run the intervals")
                continue

            # Run for at most an interval of 24 hours (or 6400 blocks)
            interval_end = block if force else function_last_run + interval
            # TODO Create ranges so we can use for..in.. instead of while..

            while (interval_end < block) or force:
                interval_function.block_last_run = interval_end
                logger.info(f"Running interval function {func.__name__} at block {interval_end}")
                try:
                    timestamp = get_block_timestamp(interval_end)
                    func(session, indx, interval_end, timestamp)
                    interval_end += interval
                except IntegrityError as e:
                    logger.error(
                        "Could not process stats on block %s",
                        interval_end,
                    )
                    logger.exception(e)
                    session.rollback()
                    continue

                if force:
                    break

    def index_events_time(self, session, indx, start_block, end_block):
        start = timer()

        self.index_events(session, indx, start_block, end_block)

        took_seconds = timer() - start
        logger.info(
            "Took %ss to listen to all events. Listened to %s blocks (range %s-%s)"
            % (took_seconds, (end_block - start_block) + 1, start_block, end_block)
        )

        if took_seconds > (end_block - start_block) + 1 * 1000:
            # Can not keep up with the blocks that are created
            logger.warning(
                "Can not keep up with the blocks that are created. Took %s seconds for %s blocks"
                % (took_seconds, (end_block - start_block) + 1)
            )

    def index_events(self, session, indx, start_block, end_block):
        logger.info("Indexing events in block range %s-%s", start_block, end_block)

        # Commit on every insert so indexer doesn't halt on single failure
        for event, func in self.events.items():
            entries = get_event_logs_in_range(session, event, start_block, end_block)
            logger.info("Found %s %s events.", len(entries), event.__name__)

            for entry in entries:
                logger.info(
                    "Processing %s event - Args: %s",
                    entry["event_name"],
                    entry["data"]["args"],
                )

                try:
                    func(
                        self,
                        session,
                        indx,
                        entry["block"],
                        entry["timestamp"],
                        entry["tx_hash"],
                        entry["data"]["args"],
                        entry["address"],
                    )
                except IntegrityError as e:
                    logger.exception(e)
                    logger.warning(
                        "Could not process an %s event from smart contract with arguments %s"
                        % (entry["event_name"], entry)
                    )
                    continue

                logger.info("Processed %s event from smart contract", entry["event_name"])


if __name__ == "__main__":
    logger.info("Started indexer process")

    indexer = Indexer()
    indexer.start()

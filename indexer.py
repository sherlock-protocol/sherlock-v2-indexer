import logging
import threading
import time
from datetime import datetime, timedelta
from decimal import Decimal, getcontext
from timeit import default_timer as timer

from sqlalchemy.exc import IntegrityError
from web3.constants import ADDRESS_ZERO

import settings
from models import (
    FundraisePositions,
    IndexerState,
    Protocol,
    ProtocolCoverage,
    ProtocolPremium,
    Session,
    StakingPositions,
    StakingPositionsMeta,
    StatsAPY,
    StatsTVC,
    StatsTVL,
)
from utils import get_event_logs_in_range, requests_retry_session, time_delta_apy

YEAR = Decimal(timedelta(days=365).total_seconds())
getcontext().prec = 78

logger = logging.getLogger(__name__)


class Indexer:
    blocks_per_call = settings.INDEXER_BLOCKS_PER_CALL

    def __init__(self, blocks_per_call=None):
        if blocks_per_call:
            self.blocks_per_call = blocks_per_call

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
        """
        self.events = {
            settings.CORE_WSS.events.Transfer: self.Transfer.new,
            settings.CORE_WSS.events.Restaked: self.Restaked.new,
            settings.CORE_WSS.events.ArbRestaked: self.Restaked.new,
            settings.SHER_BUY_WSS.events.Purchase: self.Purchase.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolAdded: self.ProtocolAdded.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolPremiumChanged: self.ProtocolPremiumChanged.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolAgentTransfer: self.ProtocolAgentTransfer.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolUpdated: self.ProtocolUpdated.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolRemoved: self.ProtocolRemoved.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolRemovedByArb: self.ProtocolRemoved.new,
        }
        self.intervals = {
            self.calc_tvl: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.calc_tvc: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.index_apy: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            # 268 blocks is roughly every hour on current Ethereum mainnet
            self.reset_apy_calc: 268,
        }

    # Also get called after listening to events with `end_block`
    def calc_factors(self, session, indx, block):
        """Compute the APY and the balance factor (the balance increase since the last computation)
        by comparing a staking position's balance at two different moments in time.

        Args:
            session: DB session
            indx: Indexer state
            block: Current block number
        """
        logger.info("Computing APY and balance factor")

        # Skip computation if meta has not been initialised yet
        # (we do not have a reference point in time - a T0).
        # Meta is initialised either on the first indexed staking event,
        # or on the first tick of `reset_apy_calc`.
        meta = StakingPositionsMeta.get(session)
        if meta.usdc_last_updated == datetime.min:
            logger.info("Meta not yet initialised. Returning...")
            return

        # Compute the time delta between current block's timestamp
        # and the last time APY was computed.
        # Skip computation if no time has passed.
        timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]
        position_timedelta = timestamp - meta.usdc_last_updated.timestamp()
        if position_timedelta == 0:
            logger.info("No time has passed since last computation. Returning...")
            return

        # Fetch an active staking position
        position = StakingPositions.get_for_factor(session)

        # Fetch current position balance as well as
        # the increase since the last computation (a.k.a the balance factor)
        usdc, factor = position.get_balance_data(block)
        logger.info("Computed a balance factor of %s", factor)

        # Compute the APY knowing the balance delta and time delta
        # TODO make compounding?
        apy = time_delta_apy(position.usdc, usdc, position_timedelta)
        logger.info("Computed an APY of %s", apy)

        # Save the computation by updating the indexer state
        indx.balance_factor = factor
        indx.block_last_updated = block
        indx.last_time = datetime.fromtimestamp(timestamp)

        # Update APY only if relevant (skip negative APYs generated by payouts).
        # Position balances are still being correctly kept up to date
        # using the balance factor which accounts for payouts.
        if apy > 0.0:
            indx.apy = apy

    def index_apy(self, session, indx, block):
        """Index current APY.

        Args:
            session: DB session
            indx: Indexer state
            block: Current block
        """
        timestamp = datetime.fromtimestamp(settings.WEB3_WSS.eth.get_block(block)["timestamp"])
        apy = indx.apy

        StatsAPY.insert(session, block, timestamp, apy)

    def calc_tvl(self, session, indx, block):
        timestamp = datetime.fromtimestamp(settings.WEB3_WSS.eth.get_block(block)["timestamp"])
        tvl = settings.CORE_WSS.functions.totalTokenBalanceStakers().call(block_identifier=block)

        StatsTVL.insert(session, block, timestamp, tvl)

    def calc_tvc(self, session, indx, block):
        timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]
        accumulated_tvc_for_block = 0

        requests = requests_retry_session()
        try:
            for row in settings.PROTOCOLS_CSV:
                if "id" not in row:
                    continue

                protocol = Protocol.get(session, row["id"])

                # Given that our datasource is the spreadsheet, the protocol could not be present in the DB yet
                if not protocol:
                    continue

                protocol_coverages = ProtocolCoverage.get_protocol_coverages(session, protocol.id)

                if not protocol_coverages:
                    continue

                protocol_coverage = protocol_coverages[0]

                # fetch protocol's TVL from DefiLlama
                response = requests.get("https://api.llama.fi/protocol/" + row["defi_llama_slug"])
                data = response.json()
                tvl_historical_data = data["chainTvls"]["Ethereum"]["tvl"]

                for tvl_data_point in reversed(tvl_historical_data):
                    if tvl_data_point["date"] < int(timestamp):
                        # Update protocol's TVL
                        protocol.tvl = tvl_data_point["totalLiquidityUSD"] * 1000000

                        # if protocol's TVL < coverage_amount => TVC = TVL, otherwise TVC = coverage_amount
                        tvc = min(protocol.tvl, protocol_coverage.coverage_amount)
                        accumulated_tvc_for_block += int(tvc)
                        break

            StatsTVC.insert(session, block, datetime.fromtimestamp(timestamp), accumulated_tvc_for_block)
        except Exception as e:
            logger.exception("TVC calc encountered exception %s" % e)

    def reset_apy_calc(self, session, indx, block):
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
        before any APY computation can be made, in order to set an
        initial point in time for the balance factor (a T0).

        Args:
            session: DB session
            indx: Indexer state
            block: Current block number
        """

        # Compute the APY only if there is a staking position available
        if StakingPositions.get_for_factor(session):
            self.calc_factors(session, indx, block)

        # Update all staking positions with current factor
        StakingPositionsMeta.update(session, block, indx.balance_factor)

        # Reset factor
        indx.balance_factor = Decimal(1)

    class Transfer:
        def new(self, session, indx, block, args):
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
            self.reset_apy_calc(session, indx, block)

            # Insert will retrieve active information (usdc, sher, lockup)
            StakingPositions.insert(
                session,
                block,
                args["tokenId"],
                args["to"],
            )

    class Purchase:
        def new(self, session, indx, block, args):
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
        def new(self, session, indx, block, args):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])

            Protocol.insert(session, protocol_bytes_id)

    class ProtocolAgentTransfer:
        def new(self, session, indx, block, args):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            new_agent = args["to"]

            Protocol.update_agent(session, protocol_bytes_id, new_agent)

    class ProtocolPremiumChanged:
        def new(self, session, indx, block, args):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            new_premium = args["newPremium"]

            protocol = Protocol.get(session, protocol_bytes_id)
            if not protocol:
                return

            timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]

            ProtocolPremium.insert(session, protocol.id, new_premium, timestamp)

    class ProtocolRemoved:
        def new(self, session, indx, block, args):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]

            Protocol.remove(session, protocol_bytes_id, timestamp)

    class Restaked:
        def new(self, session, indx, block, args):
            token_id = args["tokenID"]

            # Update all database entries to be up to date with block
            self.reset_apy_calc(session, indx, block)

            # Restake position
            StakingPositions.restake(session, block, token_id)

    class ProtocolUpdated:
        def new(self, session, indx, block, args):
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            coverage_amount = args["coverageAmount"]

            protocol = Protocol.get(session, protocol_bytes_id)
            if not protocol:
                return

            timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]

            ProtocolCoverage.update(session, protocol.id, coverage_amount, timestamp)

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

                # Process 5 blocks each round
                end_block = start_block + self.blocks_per_call - 1
                current_block = settings.WEB3_WSS.eth.blockNumber

                if end_block >= current_block:
                    end_block = current_block

                if start_block > end_block:
                    logger.info(
                        "Block %s not yet mined. Last block %s. Sleeping for %ss.",
                        start_block,
                        current_block,
                        settings.INDEXER_SLEEP_BETWEEN_CALL,
                    )
                    time.sleep(settings.INDEXER_SLEEP_BETWEEN_CALL)
                    continue

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

    def index_intervals(self, session, indx, block):
        logger.info("Running interval indexing functions")
        for func, interval in self.intervals.items():
            if block % interval >= self.blocks_per_call:
                continue

            logger.info("Running interval function  %s", func.__name__)
            try:
                func(session, indx, block)
            except IntegrityError as e:
                logger.error(
                    "Could not process stats on block %s",
                    block,
                )
                logger.exception(e)
                session.rollback()
                continue

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
            entries = get_event_logs_in_range(event, start_block, end_block)
            logger.info("Found %s %s events.", len(entries), event.__name__)

            for entry in entries:
                logger.info("Processing %s event - Args: %s", entry["event"], entry["args"].__dict__)

                try:
                    func(self, session, indx, entry["blockNumber"], entry["args"])
                    session.commit()
                except IntegrityError as e:
                    logger.exception(e)
                    logger.warning(
                        "Could not process an %s event from smart contract with arguments %s",
                        entry["event"],
                        entry["args"],
                    )
                    session.rollback()
                    continue

                logger.info("Processed %s event from smart contract", entry["event"])


if __name__ == "__main__":
    logger.info("Started indexer process")

    indexer = Indexer()
    indexer.start()

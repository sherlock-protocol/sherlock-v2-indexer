import logging
import threading
import time
import requests
from datetime import datetime, timedelta
from decimal import Decimal, getcontext
import csv

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
    StatsTVL,
    StatsTVC
)
from utils import get_event_logs_in_range, time_delta_apy

YEAR = Decimal(timedelta(days=365).total_seconds())
getcontext().prec = 78

logging.basicConfig(level=logging.INFO)
# logging.basicConfig(filename="output.log", level=logging.INFO)


class Indexer:
    blocks_per_call = settings.INDEXER_BLOCKS_PER_CALL

    def __init__(self, blocks_per_call=None):
        if blocks_per_call:
            self.blocks_per_call = blocks_per_call

        self.events = {
            settings.CORE_WSS.events.Transfer: self.Transfer.new,
            settings.CORE_WSS.events.Restaked: self.Restaked.new,
            settings.CORE_WSS.events.ArbRestaked: self.Restaked.new,
            settings.SHER_BUY_WSS.events.Purchase: self.Purchase.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolAdded: self.ProtocolAdded.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolAgentTransfer: self.ProtocolAgentTransfer.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolUpdated: self.ProtocolUpdated.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolPremiumChanged: self.ProtocolPremiumChanged.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolRemoved: self.ProtocolRemoved.new,
            settings.SHERLOCK_PROTOCOL_MANAGER_WSS.events.ProtocolRemovedByArb: self.ProtocolRemoved.new,
        }
        self.intervals = {
            self.calc_tvl: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.calc_tvc: settings.INDEXER_STATS_BLOCKS_PER_CALL,
            self.calc_factors: 1,
            # 268 blocks is roughly every hour on current Ethereum mainnet
            self.reset_apy_calc: 268
        }

    # Also get called after listening to events with `end_block`
    def calc_factors(self, session, indx, block):
        meta = StakingPositionsMeta.get(session)

        if meta.usdc_last_updated == datetime.min:
            return

        timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]
        position_timedelta = timestamp - meta.usdc_last_updated.timestamp()
        if position_timedelta == 0:
            return

        position = StakingPositions.get_for_factor(session)
        usdc, factor = position.get_balance_data(block)

        # TODO make compounding?
        apy = time_delta_apy(position.usdc, usdc, position_timedelta)

        indx.balance_factor = factor
        # If no payout has occured since the last loop
        if apy > 0.0:
            indx.apy = apy

        indx.block_last_updated = block
        indx.last_time = datetime.fromtimestamp(timestamp)

    def calc_tvl(self, session, indx, block):
        timestamp = datetime.fromtimestamp(settings.WEB3_WSS.eth.get_block(block)["timestamp"])
        tvl = settings.CORE_WSS.functions.totalTokenBalanceStakers().call(block_identifier=block)

        StatsTVL.insert(session, block, timestamp, tvl)

    def calc_tvc(self, session, indx, block):
        timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]
        accumulated_tvc_for_block = 0
        # read list of protocols from local csv file
        protocols = {}
        with open("./meta/protocols.csv", newline="") as csv_file:
            csv_reader = csv.DictReader(csv_file)
            for row in csv_reader:
                if not "id" in row:
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
                        # if protocol's TVL < coverage_amount => TVC = TVL, otherwise TVC = coverage_amount
                        tvc = min(tvl_data_point["totalLiquidityUSD"] * 1000000, protocol_coverage.coverage_amount)
                        accumulated_tvc_for_block += int(tvc)
                        break

        StatsTVC.insert(session, block, datetime.fromtimestamp(timestamp), accumulated_tvc_for_block)

    def reset_apy_calc(self, session, indx, block):
        # Do this call to get current `indx.balance_factor` value
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
            self.calc_factors(session, indx, block)

            if indx.balance_factor != Decimal(1):
                StakingPositionsMeta.update(session, block, indx.balance_factor)
                indx.balance_factor = Decimal(1)

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
            logging.debug("[+] ProtocolAdded")

            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])

            protocol = Protocol.get(session, protocol_bytes_id)
            if not protocol:
                print("Adding protocol")
                Protocol.insert(session, protocol_bytes_id)

    class ProtocolAgentTransfer:
        def new(self, session, indx, block, args):
            logging.debug("[+] ProtocolAgentTransfer")
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            new_agent = args["to"]

            Protocol.update_agent(session, protocol_bytes_id, new_agent)

    class ProtocolPremiumChanged:
        def new(self, session, indx, block, args):
            logging.debug("[+] ProtocolPremiumChanged")
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            new_premium = args["newPremium"]

            protocol = Protocol.get(session, protocol_bytes_id)
            if not protocol:
                return

            timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]

            ProtocolPremium.insert(session, protocol.id, new_premium, timestamp)

    class ProtocolRemoved:
        def new(self, session, indx, block, args):
            logging.debug("[+] ProtocolRemoved/ProtocolRemovedByArb")
            protocol_bytes_id = Protocol.parse_bytes_id(args["protocol"])
            timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]

            Protocol.remove(session, protocol_bytes_id, timestamp)

    class Restaked:
        def new(self, session, indx, block, args):
            logging.debug("[+] Restaked")
            token_id = args["tokenID"]

            StakingPositions.restake(session, token_id)

    class ProtocolUpdated:
        def new(self, session, indx, block, args):
            logging.debug("[+] ProtocolUpdated")
            print(args)

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

        t = threading.currentThread()
        logging.debug("Thread started")
        while getattr(t, "do_run", True):
            try:
                s = Session()

                # Process 5 blocks each round
                end_block = start_block + self.blocks_per_call - 1
                current_block = settings.WEB3_WSS.eth.blockNumber

                if end_block >= current_block:
                    end_block = current_block

                if start_block > end_block:
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
                logging.exception("Encountered exception %s" % e)
                time.sleep(settings.INDEXER_SLEEP_BETWEEN_CALL)

    def index_intervals(self, session, indx, block):
        for func, interval in self.intervals.items():
            if block % interval >= self.blocks_per_call:
                continue

            try:
                func(session, indx, block)
            except IntegrityError:
                logging.warning(
                    "Could not process stats on block %s",
                    block,
                )
                session.rollback()
                continue

    def index_events_time(self, session, indx, start_block, end_block):
        start = datetime.utcnow()

        self.index_events(session, indx, start_block, end_block)

        took_seconds = (datetime.utcnow() - start).microseconds / 1000
        logging.debug(
            "took %s ms to listen to all events. listened to %s blocks (range %s-%s)"
            % (took_seconds, (end_block - start_block) + 1, start_block, end_block)
        )

        if took_seconds > (end_block - start_block) + 1 * 1000:
            # Can not keep up with the blocks that are created
            logging.warning(
                "Can not keep up with the blocks that are created took %s microseconds for %s blocks"
                % (took_seconds, (end_block - start_block) + 1)
            )

    def index_events(self, session, indx, start_block, end_block):
        # Commit on every insert so indexer doesn't halt on single failure
        for event, func in self.events.items():
            entries = get_event_logs_in_range(event, start_block, end_block)
            for entry in entries:
                try:
                    func(self, session, indx, entry["blockNumber"], entry["args"])
                    session.commit()
                except IntegrityError:
                    logging.warning(
                        "Could not process an %s event from smart contract with arguments %s",
                        entry["event"],
                        entry["args"],
                    )
                    session.rollback()
                    continue

                logging.debug("Processed %s event from smart contract", entry["event"])


if __name__ == "__main__":
    print("started indexer")
    indexer = Indexer()
    indexer.start()

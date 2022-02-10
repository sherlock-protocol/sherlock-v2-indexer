import settings
import database
import threading
import logging
import time
from decimal import *

from datetime import datetime, timedelta
from web3.constants import ADDRESS_ZERO

from sqlalchemy.exc import IntegrityError

YEAR = Decimal(timedelta(days=365).total_seconds())
getcontext().prec = 78

class Indexer:
    def __init__(self):
        self.block_last_updated = 0
        self.balance_factor = Decimal(1) # if 1.0, database value is correct, if 1.1, database value is 10% less than reality
        self.apy = 0.0 # User friendly apy e.g. 3.54 --> 3.54% per year
        self.apy_50ms_factor = 0.0 # Do * balance to get apy increase
        self.events = {
            settings.CORE_WSS.events.Transfer: self.Transfer.new,
        }

        self._first_run = True

    # Also get called after listening to events with `end_block`
    def calc_factors(self, session, block):
        if self.block_last_updated == block:
            return

        meta = database.StakingPositionsMeta.get(session)
        if meta.usdc_last_updated == datetime.min:
            self.block_last_updated = block
            return

        timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]
        position_timedelta = timestamp - meta.usdc_last_updated.timestamp()

        position = database.StakingPositions.get_for_factor(session)
        usdc, factor = position.get_balance_data(block)

        # TODO make compounding?
        apy = YEAR / Decimal(position_timedelta) * (factor - 1)

        self.balance_factor = factor
        # If no payout has occured since the last loop
        if apy > 0.0:
            self.apy = round(apy * 100, 2)
            self.apy_50ms_factor = apy / YEAR / 60 / 60 / 60 / 20

        self.block_last_updated = block

    class Transfer:
        def new(self, session, block, args):
            if args["to"] == ADDRESS_ZERO:
                database.StakingPositions.delete(session, args["tokenId"])
                return

            # Update all database entries to be up to date with block
            self.calc_factors(session, block)
            if self.balance_factor != Decimal(1) or self._first_run:
                database.StakingPositionsMeta.update(
                    session, block, self.balance_factor
                )
                self.balance_factor = Decimal(1)
                self.__first_run = False

            if args["from"] == ADDRESS_ZERO:
                # Insert will retrieve active information
                database.StakingPositions.insert(
                    session, block, args["tokenId"], args["to"],
                )
                return

            # from and to both are not zero
            database.StakingPositions.update(
                session, args["tokenId"], args["to"],
            )

    def start(self):
        # get last block indexed from database
        with database.Session() as s:
            start_block = s.query(database.IndexerState).first().last_block

        t = threading.currentThread()
        logging.debug("Thread started")
        while getattr(t, "do_run", True):
            s = database.Session()

            # Process 5 blocks each round
            end_block = start_block + settings.INDEXER_BLOCKS_PER_CALL - 1
            current_block = settings.WEB3_WSS.eth.blockNumber

            if end_block >= current_block:
                end_block = current_block

            if start_block > end_block:
                time.sleep(settings.INDEXER_SLEEP_BETWEEN_CALL)
                continue

            # If think update apy factor here? So we can already use in the events

            self.index_events_time(s, start_block, end_block)
            self.calc_factors(s, end_block)

            start_block = end_block + 1
            s.query(database.IndexerState).first().last_block = start_block
            s.commit()

    def index_events_time(self, session, start_block, end_block):
        start = datetime.utcnow()

        self.index_events(session, start_block, end_block)

        took_seconds = (datetime.utcnow() - start).microseconds / 1000
        logging.debug("took %s ms to listen to all events. listened to %s blocks (range %s-%s)" % (
            took_seconds, (end_block-start_block)+1, start_block, end_block)
        )

        if took_seconds > (end_block-start_block)+1 * 1000:
            # Can not keep up with the blocks that are created
            logging.warning("Can not keep up with the blocks that are created took %s microseconds for %s blocks" % (
                took_seconds, (end_block-start_block)+1)
            )

    def index_events(self, session, start_block, end_block):
        # Commit on every insert so indexer doesn't halt on single failure
        for event, func in self.events.items():
            filter = event.createFilter(fromBlock=start_block, toBlock=end_block)
            for entry in filter.get_all_entries():
                try:
                    func(self, session, entry["blockNumber"], entry["args"])
                    session.commit()
                except IntegrityError:
                    logging.warning("Could not process an %s event from smart contract with arguments %s",
                                entry["event"], entry["args"]
                                )
                    session.rollback()
                    continue

                logging.debug("Processed %s event from smart contract", entry["event"])

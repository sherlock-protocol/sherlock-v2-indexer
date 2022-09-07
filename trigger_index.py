import logging

import settings
from indexer import Indexer
from models import IndexerState, IntervalFunction, Session

logger = logging.getLogger(__name__)


def main():
    logger.info("Triggering a manual index")
    with Session() as s:
        last_block = s.query(IndexerState).first().last_block
        interval_last_block = last_block - settings.INDEXER_STATS_BLOCKS_PER_CALL

        logger.info(
            "Last block indexed: %s. Resetting the intervals to block %s (%s blocks behind)"
            % (last_block, interval_last_block, settings.INDEXER_STATS_BLOCKS_PER_CALL)
        )
        indexer = Indexer()
        for event, func in indexer.intervals.items():
            logger.info("Updating %s interval function" % event.__name__)
            interval = IntervalFunction.get(s, event.__name__)
            interval.block_last_run = interval_last_block

        s.commit()

    logger.info("Interval functions updated successfully!")


if __name__ == "__main__":
    main()

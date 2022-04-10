import logging
import random
import time
from datetime import timedelta
from decimal import Decimal
from typing import Type

from web3.contract import ContractEvent

SECONDS_IN_A_YEAR = Decimal(timedelta(days=365).total_seconds())


def time_delta_apy(old, new, time_delta):
    """
    Compute APY based on the delta of two position balances.
    :param old: Old value (e.g. old position balance)
    :param new: New value
    :param time_delta Seconds passed between `old` and `new`
    :return: Annual Percentage Yield (1.3 => 130%)
    """
    factor = Decimal(new) / Decimal(old)
    growth = factor - 1

    growth_per_second = growth / Decimal(time_delta)
    apy = growth_per_second * SECONDS_IN_A_YEAR

    return apy


def calculate_increment(amount, apy):
    """
    Compute an amount that can be added, every second,
    to any balance affected by APY, in order generate
    a real-time balance.
    :param amount: The starting amount
    :param apy: Annual Percentage Yield (1.30 => 130%)
    :return: Increment value
    """
    one_year_yield = Decimal(amount) * Decimal(apy)

    return one_year_yield / SECONDS_IN_A_YEAR


def retry(count=3):
    """Retry decorator that wraps any function
    and retries, with exponential backoff,
    the function call `count` times when exceptions are thrown.

    Args:
        count (int, optional): Number of retries. None if should retry indefinitely. Defaults to 3.
    """

    def decorator(func):
        def retry_func(*args, **kwargs):
            attempt = 0

            while count is None or attempt < count:
                try:
                    return func(*args, **kwargs)
                except Exception as ex:
                    logging.exception(ex)

                    delay = 2**attempt + random.uniform(0, 1)
                    time.sleep(delay)

                    attempt += 1

            return func(*args, **kwargs)

        return retry_func

    return decorator


@retry(count=5)
def get_event_logs_in_range(event: Type[ContractEvent], start_block: int, end_block: int):
    """Fetches the event logs in a range of blocks.
    Retries on failure.

    Args:
        event (Type[ContractEvent]): Event to filter
        start_block (int): Filter events starting from this block number
        end_block (int): Filter events until this block number

    Returns:
        list: List of events
    """

    filter = event.createFilter(fromBlock=start_block, toBlock=end_block)
    return filter.get_all_entries()

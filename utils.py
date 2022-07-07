import logging
import random
import time
from datetime import timedelta
from decimal import Decimal
from typing import Type

import requests
from requests.adapters import HTTPAdapter
from urllib3 import Retry
from web3.contract import ContractEvent

SECONDS_IN_A_YEAR = Decimal(timedelta(days=365).total_seconds())

logger = logging.getLogger(__name__)


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


def get_premiums_apy(tvl, apy, premiums):
    """
    Compute APY % generated only by premiums.
    :param tvl: Current TVL.
    :param apy: Total APY.
    :param premiums: USDC amount of premiums generated per second.
    :return: Annual Percentage Yield of premiums (1.3 => 130%)
    """
    premiums_annual_yield = Decimal(premiums) * SECONDS_IN_A_YEAR
    return premiums_annual_yield / Decimal(tvl)


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
                    logger.exception(ex)

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


def requests_retry_session(
    retries=5,
    backoff_factor=1,
    status_forcelist=tuple(x for x in requests.status_codes._codes if x / 100 != 2 and x / 100 != 1),
    session=None,
):
    """Create a `requests` session that retries on certain error codes.

    Args:
        retries (int, optional): Number of attempted retries after the initial request. Defaults to 5.
        backoff_factor (int, optional): Exponential backoff factor. Defaults to 1.
        status_forcelist (List[int], optional): List of HTTP status codes that should trigger a retry.
                                                Defaults to all except 1XX and 2XX.
        session (Session, optional): `requests` session to setup retries for.
                                     If not specified, a new `requests` session will be created.

    Returns:
        Session: `requests` session
    """
    # Generate new session or use the provided one
    session = session or requests.Session()

    # Setup retry adapter
    retry = Retry(
        total=retries,
        read=retries,
        connect=retries,
        backoff_factor=backoff_factor,
        status_forcelist=status_forcelist,
    )
    adapter = HTTPAdapter(max_retries=retry)

    # Apply retry adapter to HTTP and HTTP requests
    session.mount("http://", adapter)
    session.mount("https://", adapter)

    return session

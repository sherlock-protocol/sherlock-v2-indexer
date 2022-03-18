from datetime import timedelta
from decimal import Decimal

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

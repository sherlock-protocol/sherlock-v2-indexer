import math
from decimal import Decimal

import pytest

from utils import time_delta_apy, SECONDS_IN_A_YEAR, calculate_increment


@pytest.mark.parametrize("old, new, time_delta, apy",
                         [(1, 1.01, 1, SECONDS_IN_A_YEAR / 100),
                          (1, 1.02, 1, 2 * SECONDS_IN_A_YEAR / 100),
                          (1, 1.01, 2, SECONDS_IN_A_YEAR / 100 / 2),
                          (1, 1.25, SECONDS_IN_A_YEAR / 4, 1)])
def test_apy_computed_correctly(old, new, time_delta, apy):
    computed_apy = time_delta_apy(old, new, time_delta)

    # Check equality with a 1e-6 (6 decimals) precision
    assert math.isclose(apy, computed_apy, rel_tol=1e-6)


@pytest.mark.parametrize("apy, amount, time_delta",
                         [(Decimal(2), Decimal(1), SECONDS_IN_A_YEAR ),
                          (Decimal(39), Decimal(324.98), 120),
                          (Decimal(0.04), Decimal(1000), 1)])
def test_increment_computed_correctly(apy, amount, time_delta):
    # Compute the increment from the APY and the amount
    increment = calculate_increment(amount, apy)

    # Compute the amount after `time_delta` seconds
    new_amount = amount + (increment * time_delta)

    # Compute APY from the change
    resulting_apy = time_delta_apy(amount, new_amount, time_delta)

    # Resulting APY should be the same as the one used for calculating the APY
    # Check equality with a 1e-6 (6 decimals) precision
    assert math.isclose(resulting_apy, apy, rel_tol=1e-6)

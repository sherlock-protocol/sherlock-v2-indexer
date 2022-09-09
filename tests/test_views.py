import pytest

from views.protocols import get_protocols
from populate_testing_db import *


def test_view():
    protocols = get_protocols()

    assert len(protocols["data"]) == 2

    assert protocols["data"][0]["agent"] == PROTOCOL1_AGENT
    assert protocols["data"][0]["premium"] == 100
    assert protocols["data"][0]["bytes_identifier"] == PROTOCOL1
    assert protocols["data"][0]["coverage_ended_at"] is None
    assert len(protocols["data"][0]["coverages"]) == 2
    assert protocols["data"][0]["coverages"][0]["claimable_until"] is None
    assert protocols["data"][0]["coverages"][0]["coverage_amount"] == 2000
    assert protocols["data"][0]["coverages"][1]["claimable_until"] is None
    assert protocols["data"][0]["coverages"][1]["coverage_amount"] == 1000

    assert protocols["data"][1]["agent"] == PROTOCOL2_AGENT
    assert protocols["data"][1].get("premium") is None
    assert protocols["data"][1]["bytes_identifier"] == PROTOCOL2
    assert protocols["data"][1]["coverage_ended_at"] is None
    assert len(protocols["data"][1]["coverages"]) == 1
    assert protocols["data"][1]["coverages"][0]["claimable_until"] is None
    assert protocols["data"][1]["coverages"][0]["coverage_amount"] == 3000

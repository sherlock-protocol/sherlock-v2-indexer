import pytest

from views.protocols import get_protocols

# RUN `psql -U postgres -d indexer_test -f test_database.sql`

def test_view():
    protocols = get_protocols()

    assert len(protocols["data"]) == 7

    for i in range(0, 6):
        # All these have 19 keys (including premium)
        assert len(protocols["data"][i]) == 19
        assert protocols["data"][i].get("premium") is not None
        assert protocols["data"][i].get("premium_set_at") is not None

    # Assert latest premiums are used
    assert protocols["data"][0].get("premium") == 1177
    assert protocols["data"][1].get("premium") == 4756
    assert protocols["data"][2].get("premium") == 5391
    assert protocols["data"][3].get("premium") == 2180
    assert protocols["data"][4].get("premium") == 6342
    assert protocols["data"][5].get("premium") == 159

    # Has 17 keys (excluding premium)
    non_premium_object = protocols["data"][6]
    assert len(non_premium_object) == 17
    assert non_premium_object.get("premium") is None
    assert non_premium_object.get("premium_set_at") is None


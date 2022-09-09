import os
# HACK to choose testing databse
os.environ["PYTEST_CURRENT_TEST"] = "fake"

# os.environ["PYTEST_CURRENT_TEST"] = "fake"
# DROP SCHEMA public CASCADE; CREATE SCHEMA public;
# alembic upgrade head && python database.py 100
# python populate_testing_db.py
# pytest tests/test_views.py -v

from models import (
    Protocol,
    ProtocolCoverage,
    ProtocolPremium,
    Session,
)

s = Session()

PROTOCOL1 = "0x0000000000000000000000000000000000000000000000000000000000000001"
PROTOCOL1_AGENT = "0x0000000000000000000000000000000000000001"


PROTOCOL2 = "0x0000000000000000000000000000000000000000000000000000000000000002"
PROTOCOL2_AGENT = "0x0000000000000000000000000000000000000002"


def main():
    Protocol.insert(s, PROTOCOL1)
    Protocol.update_agent(s, PROTOCOL1, PROTOCOL1_AGENT)
    s.commit()
    ProtocolCoverage.update(s, 1, "1000", 1)
    s.commit()
    ProtocolPremium.insert(s, 1, 50, 2)
    s.commit()
    ProtocolCoverage.update(s, 1, "2000", 3)
    ProtocolPremium.insert(s, 1, 100, 4)
    s.commit()

    Protocol.insert(s, PROTOCOL2)
    Protocol.update_agent(s, PROTOCOL2, PROTOCOL2_AGENT)
    s.commit()
    ProtocolCoverage.update(s, 2, "3000", 3)
    s.commit()

if __name__ == "__main__":
    main()

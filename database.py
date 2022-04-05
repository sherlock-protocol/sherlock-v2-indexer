import sys

from models import IndexerState, Session, StakingPositionsMeta


def run(start_block):
    s = Session()
    s.add(StakingPositionsMeta())
    i = IndexerState()
    i.last_block = start_block
    s.add(i)
    s.commit()
    s.close()


def main():
    if len(sys.argv) != 2:
        sys.exit("Usage: python database.py <start-block>")
    try:
        start_block = int(sys.argv[1])
    except ValueError:
        sys.exit("Usage: python database.py <start-block>")

    run(start_block)


if __name__ == "__main__":
    main()

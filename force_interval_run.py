import argparse

import indexer
from models import IndexerState, Session


def main():
    parser = argparse.ArgumentParser(description="Forces all interval functions to run")
    parser.add_argument(
        "-b", "--block", metavar="block", type=int, help="Block to run interval functions", required=False
    )
    args = parser.parse_args()

    index = indexer.Indexer()
    with Session() as s:
        # Explicitly lock table
        # Will make the indexer thread wait if it tries to acquire the same table
        s.execute("select pg_advisory_xact_lock(1)")
        indx = s.query(IndexerState).first()
        block = args.block if args.block else indx.last_block

        try:
            # We can run the function before the interval needs to run, e.g. `t=8` and indexer `t=9`
            # But we can not run the interval function for block `t=10` if the indexer is at `t=9`
            assert block <= indx.last_block, "Can not run interval function in the future"

            index.index_intervals(s, indx, block, force=True)

            # Verify if output looks ok
            print("Does output look correct to you? Wish to commit database? (y/n)")

            # NOTE: leaving input field open will make the full indexer wait!
            answer = input()
            while answer not in ["y", "n"]:
                print("Please press 'y' or 'n'")
                answer = input()

            if answer == "y":
                print("Committing interval run")
                s.commit()
            else:
                print("Not comitting changes")
                s.rollback()

            s.close()
        except Exception:
            s.rollback()
            s.close()
            raise


if __name__ == "__main__":
    main()

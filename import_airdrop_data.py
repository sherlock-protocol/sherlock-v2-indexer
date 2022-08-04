import argparse
import json
from decimal import Decimal

import settings  # noqa
from models import Airdrop, Session


def main():
    parser = argparse.ArgumentParser(description="Import Merkle Tree data")
    parser.add_argument(
        "-f", "--file", metavar="path", type=argparse.FileType("r"), help="JSON file to import", required=True
    )
    parser.add_argument(
        "-c", "--contract", metavar="address", type=str, help="Merkle Distributor contract address", required=True
    )
    parser.add_argument("-t", "--token", metavar="symbol", type=str, help="ERC20 token symbol", required=True)

    args = parser.parse_args()

    data = json.loads(args.file.read())

    # Add to database
    with Session() as s:
        for address, claim in data["claims"].items():
            Airdrop.insert(
                s, claim["index"], address, Decimal(int(claim["amount"], 16)), args.token, args.contract, claim["proof"]
            )

        s.commit()

    print("Success!")


if __name__ == "__main__":
    main()

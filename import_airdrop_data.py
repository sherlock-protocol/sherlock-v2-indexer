import json
import sys
from decimal import Decimal

import settings  # noqa
from models import Airdrop, Session


def main():
    assert len(sys.argv) >= 2, "Please provide a file to import"
    filename = sys.argv[1]

    with open(filename, "r") as file:
        data = json.loads(file.read())

    # Add to database
    with Session() as s:
        for address, claim in data["claims"].items():
            Airdrop.insert(s, claim["index"], address, Decimal(int(claim["amount"], 16)), claim["proof"])

        s.commit()

    print("Success!")


if __name__ == "__main__":
    main()

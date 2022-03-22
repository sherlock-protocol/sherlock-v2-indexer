from web3 import Web3

from flask_app import app
from models import FundraisePositions, Session


@app.route("/positions/<user>/fundraise")
def fundraise_positions(user):
    if not Web3.isChecksumAddress(user):
        return {"ok": False, "error": "Argument should be checksummed address"}

    with Session() as s:
        position = FundraisePositions.get(s, user)

    if position is None:
        return {"ok": True, "data": None}

    return {"ok": True, "data": position.to_dict()}

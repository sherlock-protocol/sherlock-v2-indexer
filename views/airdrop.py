from web3 import Web3

from flask_app import app
from models import Airdrop, Session


@app.route("/airdrop/<user>")
def get_airdrop_claims(user=None):
    if user:
        if not Web3.isChecksumAddress(user):
            return {"ok": False, "error": "Argument should be checksummed address"}

    with Session() as s:
        claims = Airdrop.get(s, user) if user else []

    # Transform positions in list of dictionaries
    claims = [x.to_dict() for x in claims]

    return {
        "ok": True,
        "data": claims,
    }

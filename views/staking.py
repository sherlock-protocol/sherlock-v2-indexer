from web3 import Web3

from flask_app import app
from models import IndexerState, Session, StakingPositions
from utils import calculate_increment

@app.route("/positions/<user>/staking")
def staking_positions(user):
    if not Web3.isChecksumAddress(user):
        return {"ok": False, "error": "Argument should be checksummed address"}

    with Session() as s:
        positions = StakingPositions.get(s, user)
        indexer_data = s.query(IndexerState).first()

    # Transform positions in list of dictionaries
    positions = [x.to_dict() for x in positions]

    # Compute USDC increment and updated balance
    # TODO temporary fixed apy
    apy = 0.15

    for pos in positions:
        pos["usdc_increment"] = calculate_increment(pos["usdc"], apy)
        pos["usdc"] = round(pos["usdc"] * indexer_data.balance_factor)

    return {
        "ok": True,
        "positions_usdc_last_updated": int(indexer_data.last_time.timestamp()),
        "usdc_apy": round(apy * 100, 6),
        "data": positions,
    }

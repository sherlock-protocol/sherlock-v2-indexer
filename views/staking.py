from web3 import Web3

import settings
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
    apy = indexer_data.apy

    for pos in positions:
        print(pos)
        position_apy = (
            0.15 if (pos["id"] <= settings.LAST_POSITION_ID_FOR_15PERC_APY and pos["restake_count"] == 0) else apy
        )

        pos["usdc_increment"] = calculate_increment(pos["usdc"], position_apy)
        pos["usdc"] = round(pos["usdc"] * indexer_data.balance_factor)
        pos["usdc_apy"] = round(position_apy * 100, 6)

    return {
        "ok": True,
        "positions_usdc_last_updated": int(indexer_data.last_time.timestamp()),
        "usdc_apy": round(apy * 100, 6),
        "data": positions,
    }

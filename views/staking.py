from web3 import Web3

import settings
from flask_app import app
from models import IndexerState, Session, StakingPositions
from utils import calculate_increment


@app.route("/positions/<user>/staking")
@app.route("/staking/<user>")
@app.route("/staking")
def staking_positions(user=None):
    if user:
        if not Web3.isChecksumAddress(user):
            return {"ok": False, "error": "Argument should be checksummed address"}

    with Session() as s:
        positions = StakingPositions.get(s, user) if user else []
        indexer_data = s.query(IndexerState).first()

    # Transform positions in list of dictionaries
    positions = [x.to_dict() for x in positions]

    # Compute USDC increment and updated balance
    apy = indexer_data.apy
    additional_apy = indexer_data.additional_apy
    expected_apy = apy + additional_apy

    for pos in positions:
        if pos["id"] <= settings.LAST_POSITION_ID_FOR_15PERC_APY and pos["restake_count"] == 0:
            position_apy = 0.15
            pos["usdc_increment"] = calculate_increment(pos["usdc"], position_apy)
        else:
            position_apy = expected_apy
            pos["usdc_increment"] = calculate_increment(pos["usdc"], apy)

        pos["usdc"] = round(pos["usdc"] * indexer_data.balance_factor)
        pos["usdc_apy"] = round(position_apy * 100, 6)

    return {
        "ok": True,
        "positions_usdc_last_updated": int(indexer_data.last_time.timestamp()),
        "usdc_apy": round(expected_apy * 100, 6),
        "data": positions,
    }

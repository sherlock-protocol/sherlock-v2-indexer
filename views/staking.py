from web3 import Web3

from flask_app import app
from models import IndexerState, Session, StakingPositions
from utils import calculate_increment
from settings import LAST_POSITION_ID_FOR_15PERC_APY


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
        # TODO include counter in `StakingPositions` of how many times the position has been restaked
        # TODO if pos.restaked == 0 && pos.id <= settings.LAST_POSITION_ID_FOR_15PERC_APY:
        # TODO ^ to not show 15% APY when the users restake after 6 months
        if pos.id <= LAST_POSITION_ID_FOR_15PERC_APY:
            apy = 0.15

        pos["usdc_increment"] = calculate_increment(pos["usdc"], apy)
        pos["usdc"] = round(pos["usdc"] * indexer_data.balance_factor)

    return {
        "ok": True,
        "positions_usdc_last_updated": int(indexer_data.last_time.timestamp()),
        "usdc_apy": round(indexer_data.apy * 100, 6), # Will not be affected by `LAST_POSITION_ID_FOR_15PERC_APY`
        "data": positions,
    }

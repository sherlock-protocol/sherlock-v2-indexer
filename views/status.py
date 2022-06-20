from flask_app import app
from models import IndexerState, Session, StakingPositions, StakingPositionsMeta


@app.route("/status")
def status():
    with Session() as s:
        indexer_state = s.query(IndexerState).first()
        staking_positions_meta = s.query(StakingPositionsMeta).first()
        all_positions = s.query(StakingPositions).all()

    return {
        "ok": True,
        "data": {
            "last_block": indexer_state.last_block,
            "last_time": int(indexer_state.last_time.timestamp()),
            "apy": indexer_state.apy,
            "balance_factor": indexer_state.balance_factor,
            "usdc_last_updated": int(staking_positions_meta.usdc_last_updated.timestamp()),
            "usdc_last_updated_block": staking_positions_meta.usdc_last_updated_block,
            "staking_positions": [x.to_dict() for x in all_positions],
        },
    }

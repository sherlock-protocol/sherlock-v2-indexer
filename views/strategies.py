from flask_app import app
from models import Session, StrategyBalance


@app.route("/strategies")
def strategies():
    with Session() as s:
        strategies = (
            s.query(StrategyBalance)
            .distinct(StrategyBalance.address)
            .order_by(StrategyBalance.address, StrategyBalance.timestamp.desc())
            .all()
        )

    # Transform rows in list of dictionaries
    strategies = [x.to_dict() for x in strategies]

    return {
        "ok": True,
        "data": strategies,
    }

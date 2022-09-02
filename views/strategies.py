from flask_app import app
from models import Session, StrategyBalance
from strategies.strategies import Strategies


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
    data = []
    for strategy in strategies:
        strat_obj = Strategies.get(strategy.address)

        # Don't include strategies with 0 value
        if strategy.value == 0:
            continue

        data.append({**strategy.to_dict(), "name": strat_obj.name if strat_obj else "Unknown"})

    return {"ok": True, "data": data}

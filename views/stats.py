from datetime import datetime

import sqlalchemy as sa
from flask import request

from flask_app import app
from models import Session, StatsAPY, StatsTVC, StatsTVL
from models.staking_position import StakingPositions


@app.route("/stats_tvl")
def sherlock_stats():
    args = request.args
    with Session() as s:
        offset = args.get("offset", default=0)
        limit = args.get("limit", default=365)

        stats = StatsTVL.find_all(s, offset, limit)

    # Transform rows in list of dictionaries
    stats = [x.to_dict() for x in stats]

    return {
        "ok": True,
        "data": stats,
    }


@app.route("/stats_tvc")
def stats_tvc():
    args = request.args
    with Session() as s:
        offset = args.get("offset", default=0)
        limit = args.get("limit", default=365)

        stats = StatsTVC.find_all(s, offset, limit)

    # Transform rows in list of dictionaries
    stats = [x.to_dict() for x in stats]

    return {
        "ok": True,
        "data": stats,
    }


@app.route("/stats/apy")
def stats_apy():
    args = request.args
    with Session() as s:
        offset = args.get("offset", default=0)
        limit = args.get("limit", default=365)

        stats = StatsAPY.find_all(s, offset, limit)

    # Transform rows in list of dictionaries
    stats = [x.to_dict() for x in stats]

    return {
        "ok": True,
        "data": stats,
    }


@app.route("/stats/unlock")
def stats_unlock():
    with Session() as s:
        # Fetch all StakingPositions and apply a GROUP BY to sum the values of positions
        # in the same day, and sort them ascending.
        # We cast `lockup_end` to DATE in order to loose the time part, so we can group them by day.
        all_positions = (
            s.query(sa.cast(StakingPositions.lockup_end, sa.Date).label("date"), sa.func.sum(StakingPositions.usdc))
            .group_by(sa.text("date"))
            .order_by(sa.text("date asc"))
            .all()
        )

    if len(all_positions) == 0:
        return {"ok": True, "data": []}

    # Compute total value
    total_value_locked = sum(x[1] for x in all_positions)

    data_points = []

    # Add initial data point, with the full TVL, at T0=NOW
    initial_timestamp = datetime.now()
    data_points.append({"timestamp": int(initial_timestamp.timestamp()), "value": total_value_locked})

    # Iterate through all positions and create a new data point
    # for each unlock date. The value of each data point is equal to
    # the TVL minus the value of all staking positions unstaked by that time.
    for position in all_positions:
        total_value_locked -= position[1]
        # We convert date to datetime
        timestamp = datetime.combine(position[0], datetime.min.time())
        data_points.append({"timestamp": int(timestamp.timestamp()), "value": total_value_locked})

    return {
        "ok": True,
        "data": data_points,
    }

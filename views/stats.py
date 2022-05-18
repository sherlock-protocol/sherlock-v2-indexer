from datetime import datetime

from flask import request
from sqlalchemy import asc, func

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
        # with the same unlock timestamp, and sort them by the lockup period.
        all_positions = (
            s.query(StakingPositions.lockup_end, func.sum(StakingPositions.usdc))
            .group_by(StakingPositions.lockup_end)
            .order_by(asc(StakingPositions.lockup_end))
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
        data_points.append({"timestamp": int(position[0].timestamp()), "value": total_value_locked})

    return {
        "ok": True,
        "data": data_points,
    }

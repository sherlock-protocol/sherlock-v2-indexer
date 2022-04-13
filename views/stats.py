from flask_app import app
from flask import request
from models import Session, StatsTVL, StatsTVC


@app.route("/sherlock_stats")
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

        stats = StatsTVL.find_all(s, offset, limit)

    # Transform rows in list of dictionaries
    stats = [x.to_dict() for x in stats]

    return {
        "ok": True,
        "data": stats,
    }

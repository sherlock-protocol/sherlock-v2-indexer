from flask_app import app
from models import Session, StatsTVL


@app.route("/sherlock_stats")
def sherlock_stats():
    with Session() as s:
        stats = StatsTVL.find_all(s)

    # Transform rows in list of dictionaries
    stats = [x.to_dict() for x in stats]

    return {
        "ok": True,
        "data": stats,
    }

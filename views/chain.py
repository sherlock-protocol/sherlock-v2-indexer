from flask import jsonify

from flask_app import app
from models import IndexerState, Session


@app.route("/last-block-indexed")
def get_last_block_indexed():
    """Fetch the last block indexed by the indexer."""

    with Session() as s:
        last_block = s.query(IndexerState.last_block).scalar()

    return jsonify(last_block), 200

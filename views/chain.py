import time

from flask import request

from flask_app import app
from models import IndexerState, Session


@app.route("/wait-for-block")
def wait_for_block():
    """Wait for a block to get processed before returning.

    Will be called as `GET /wait-for-block?block=123`,
    where 123 is the block we need to wait for.
    """
    with Session() as s:
        block = request.args.get("block")

        if not block:
            return {"ok": False, "error": "Block param is mandatory."}

        block = int(block)

        # Maximum number of seconds to wait for the block to get indexer.
        # Nginx's timeout should be changed according to this setting as well.
        max_tries = 60
        try_count = 0

        while try_count < max_tries:
            last_indexer_block = s.query(IndexerState).first().last_block

            if last_indexer_block > block:
                return {"ok": True}

            time.sleep(1)
            try_count += 1

        return {"ok": False, "error": "Exceeded maximum waiting time."}

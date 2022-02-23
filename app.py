
import signal
import sys
import atexit
import settings
import database

from threading import Thread
from flask import Flask
from flask_cors import CORS

from indexer import Indexer
indexer = Indexer()

from web3 import Web3

app = Flask(__name__)
CORS(app)

@app.route("/positions/<user>/staking")
def staking_positions(user):
    if not Web3.isChecksumAddress(user):
        return {
            "ok": False,
            "error": "Argument should be checksummed address"
        }

    with database.Session() as s:
        positions = database.StakingPositions.get(s, user)
        indexer_data = s.query(database.IndexerState).first()

    for pos in positions:
        pos.usdc = round(pos.usdc * indexer_data.balance_factor)

    return {
        "ok": True,
        "positions_usdc_last_updated": int(indexer_data.last_time.timestamp()),
        "usdc_apy": indexer_data.apy,
        "usdc_increment_50ms_factor": indexer_data.apy_50ms_factor,
        "data": [x.to_dict() for x in positions]
    }

@app.route("/positions/<user>/fundraise")
def fundraise_positions(user):
    if not Web3.isChecksumAddress(user):
        return {
            "ok": False,
            "error": "Argument should be checksummed address"
        }

    with database.Session() as s:
        position = database.FundraisePositions.get(s, user)

    if position is None:
        return {
            "ok": True,
            "data": None
        }

    return {
        "ok": True,
        "data": position.to_dict()
    }

threads = []

def signal_handler(sig, frame):
    print('You pressed Ctrl+C!')
    print("Waiting for %s threads" % len(threads))
    for t in threads:
        t.do_run = False
        t.join()
    sys.exit(0)

def interrupt():
    signal_handler(None, None)

def create_app():
    thread = Thread(name="Indexer started", target=indexer.start)
    threads.append(thread)
    thread.start()

    signal.signal(signal.SIGINT, signal_handler)
    atexit.register(interrupt)

    return app

app = create_app()

if __name__ == "__main__":
    app.run(host=settings.API_HOST, port=settings.API_PORT, debug=settings.API_DEBUG)


import signal
import sys
import atexit
import settings
import database

from threading import Thread
from flask import Flask

from indexer import Indexer

from web3 import Web3

app = Flask(__name__)

@app.route("/positions/<user>")
def positions(user):
    if not Web3.isChecksumAddress(user):
        return {
            "ok": False,
            "error": "Argument should be checksummed address"
        }


    with database.Session() as s:
        positions = database.StakingPositions.get(s, user)

    for pos in positions:
        pos.usdc *= 

    for pos in positions:
        print(pos.usdc)
    print(positions)
    return {
        "ok": True,
        # "data": positions
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
    indexer = Indexer()
    thread = Thread(name="Indexer started", target=indexer.start)
    threads.append(thread)
    thread.start()

    signal.signal(signal.SIGINT, signal_handler)
    atexit.register(interrupt)

    return app

app = create_app()

if __name__ == "__main__":
    app.run(host=settings.API_HOST, port=settings.API_PORT, debug=settings.API_DEBUG)
import atexit
import signal
import sys
from threading import Thread

import sentry  # noqa
import settings
from flask_app import app
from indexer import Indexer

indexer = Indexer()

threads = []


def signal_handler(sig, frame):
    print("You pressed Ctrl+C!")
    print("Waiting for %s threads" % len(threads))
    for t in threads:
        t.do_run = False
        t.join()
    sys.exit(0)


def interrupt():
    signal_handler(None, None)


def create_indexer():
    thread = Thread(name="Indexer started", target=indexer.start)
    threads.append(thread)
    thread.start()

    signal.signal(signal.SIGINT, signal_handler)
    atexit.register(interrupt)

    return app


indexer = create_indexer()

if __name__ == "__main__":
    indexer.run(host=settings.API_HOST, port=settings.API_PORT, debug=settings.API_DEBUG)

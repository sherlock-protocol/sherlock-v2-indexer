from flask import Flask
from flask_cors import CORS

from indexer import Indexer

indexer = Indexer()


app = Flask(__name__)
CORS(app)

import views  # noqa

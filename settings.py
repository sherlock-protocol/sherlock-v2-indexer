from sqlalchemy import create_engine
from decouple import config

from web3 import Web3, HTTPProvider, WebsocketProvider

import os
import json

API_HOST = config('API_HOST', default='127.0.0.1')
API_PORT = config('API_PORT', default=5000, cast=int)
API_DEBUG = config('API_DEBUG', default=False, cast=bool)

DB_USER = config('DB_USER')
DB_PASS = config('DB_PASS')
DB_PORT = config('DB_PORT')
DB_NAME = config('DB_NAME')

DB = create_engine('postgresql+psycopg2://{}:{}@localhost:{}/{}'.format(
    DB_USER, DB_PASS, DB_PORT, DB_NAME
), echo=False)

# Web3 connection
WEB3_WSS = Web3(WebsocketProvider(config('WEB3_PROVIDER_WSS')))

# Repo location on system
REPO = config('SHERLOCK_V2_CORE_PATH')

CORE_ADDRESS = config('SHERLOCK_V2_CORE')
with open(os.path.join(REPO, 'artifacts', 'contracts', 'Sherlock.sol', 'Sherlock.json')) as json_data:
    CORE_ABI = json.load(json_data)["abi"]
CORE_WSS = WEB3_WSS.eth.contract(address=CORE_ADDRESS, abi=CORE_ABI)

INDEXER_BLOCKS_PER_CALL = 5
INDEXER_SLEEP_BETWEEN_CALL = config('INDEXER_SLEEP_BETWEEN_CALL', default=5.0, cast=float)
import csv
import json
import os
from logging import Formatter, StreamHandler, getLogger
from logging.handlers import TimedRotatingFileHandler

from decouple import config
from sqlalchemy import create_engine
from web3 import Web3, WebsocketProvider
from web3.middleware import geth_poa_middleware

API_HOST = config("API_HOST", default="127.0.0.1")
API_PORT = config("API_PORT", default=5000, cast=int)
API_DEBUG = config("API_DEBUG", default=False, cast=bool)

DB_USER = config("DB_USER")
DB_PASS = config("DB_PASS")
DB_PORT = config("DB_PORT")
DB_NAME = config("DB_NAME")

DATABASE_URI = "postgresql+psycopg2://{}:{}@localhost:{}/{}".format(DB_USER, DB_PASS, DB_PORT, DB_NAME)
DB = create_engine(
    DATABASE_URI,
    echo=False,
)

# Web3 connection
WEB3_WSS = Web3(WebsocketProvider(config("WEB3_PROVIDER_WSS"), websocket_timeout=180))
if "goerli" in config("WEB3_PROVIDER_WSS"):
    WEB3_WSS.middleware_onion.inject(geth_poa_middleware, layer=0)

# Repo location on system
REPO = config("SHERLOCK_V2_CORE_PATH")

CORE_ADDRESS = config("SHERLOCK_V2_CORE")
with open(os.path.join(REPO, "artifacts", "contracts", "Sherlock.sol", "Sherlock.json")) as json_data:
    CORE_ABI = json.load(json_data)["abi"]
CORE_WSS = WEB3_WSS.eth.contract(address=CORE_ADDRESS, abi=CORE_ABI)

SHER_BUY_ADDRESS = config("SHERLOCK_V2_SHER_BUY")
with open(os.path.join(REPO, "artifacts", "contracts", "SherBuy.sol", "SherBuy.json")) as json_data:
    SHER_BUY_ABI = json.load(json_data)["abi"]
SHER_BUY_WSS = WEB3_WSS.eth.contract(address=SHER_BUY_ADDRESS, abi=SHER_BUY_ABI)

SHER_CLAIM_ADDRESS = config("SHERLOCK_V2_SHER_CLAIM")
with open(os.path.join(REPO, "artifacts", "contracts", "SherClaim.sol", "SherClaim.json")) as json_data:
    SHER_CLAIM_ABI = json.load(json_data)["abi"]
SHER_CLAIM_WSS = WEB3_WSS.eth.contract(address=SHER_CLAIM_ADDRESS, abi=SHER_CLAIM_ABI)

SHERLOCK_PROTOCOL_MANAGER_ADDRESS = config("SHERLOCK_V2_PROTOCOL_MANAGER")
with open(
    os.path.join(
        REPO, "artifacts", "contracts", "managers", "SherlockProtocolManager.sol", "SherlockProtocolManager.json"
    )
) as json_data:
    SHERLOCK_PROTOCOL_MANAGER_ABI = json.load(json_data)["abi"]
SHERLOCK_PROTOCOL_MANAGER_WSS = WEB3_WSS.eth.contract(
    address=SHERLOCK_PROTOCOL_MANAGER_ADDRESS, abi=SHERLOCK_PROTOCOL_MANAGER_ABI
)

SHER_CLAIM_AT = SHER_CLAIM_WSS.functions.newEntryDeadline().call() + 60 * 60 * 24 * 7 * 26  # + 26 weeks

INDEXER_BLOCKS_PER_CALL = 5
INDEXER_STATS_BLOCKS_PER_CALL = 6400
INDEXER_SLEEP_BETWEEN_CALL = config("INDEXER_SLEEP_BETWEEN_CALL", default=5.0, cast=float)

# Will be used to flag the last position ID that get's 15% apy
LAST_POSITION_ID_FOR_15PERC_APY = config("LAST_POSITION_ID_FOR_15PERC_APY", cast=int, default=10000000000000)

# Protocols (from local csv file, kept in memory)
with open("./meta/protocols.csv", newline="") as csv_file:
    PROTOCOLS_CSV = list(csv.DictReader(csv_file))

# LOGGING
# ------------------------------------------------------------------------------
logger = getLogger()
logger.setLevel("DEBUG")

# Create custom formatter
verbose_formatter = Formatter(
    (
        "[%(asctime)s] %(levelname)-7s "
        "%(module)s %(name)s "
        "{%(filename)s:%(lineno)d} %(process)d %(thread)d - %(message)s"
    )
)

# Setup file logging using file rotation at midnight
file_handler = TimedRotatingFileHandler(filename="output.log", when="midnight", utc=True)
file_handler.setLevel("DEBUG")
file_handler.setFormatter(verbose_formatter)

# Setup console logging
console_handler = StreamHandler()
console_handler.setLevel("DEBUG")
console_handler.setFormatter(verbose_formatter)

logger.handlers = []
logger.addHandler(console_handler)
logger.addHandler(file_handler)

# Disable websockets protocol loggers
getLogger("websockets.protocol").setLevel("INFO")

# Disable web3.py loggers
getLogger("web3").setLevel("INFO")

import csv
import json
import os
from logging import Formatter, StreamHandler, getLogger

from concurrent_log_handler import ConcurrentRotatingFileHandler
from decouple import Csv, config
from sqlalchemy import create_engine
from web3 import Web3, WebsocketProvider
from web3.middleware import geth_poa_middleware
from collections import OrderedDict

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

SHERLOCK_CLAIM_MANAGER_ADDRESS = config("SHERLOCK_V2_CLAIM_MANAGER")
with open(
    os.path.join(REPO, "artifacts", "contracts", "managers", "SherlockClaimManager.sol", "SherlockClaimManager.json")
) as json_data:
    SHERLOCK_CLAIM_MANAGER_ABI = json.load(json_data)["abi"]
SHERLOCK_CLAIM_MANAGER_WSS = WEB3_WSS.eth.contract(
    address=SHERLOCK_CLAIM_MANAGER_ADDRESS, abi=SHERLOCK_CLAIM_MANAGER_ABI
)

with open(
    os.path.join(REPO, "artifacts", "contracts", "strategy", "base", "BaseStrategy.sol", "BaseStrategy.json")
) as json_data:
    STRATEGY_ABI = json.load(json_data)["abi"]

SHER_CLAIM_AT = SHER_CLAIM_WSS.functions.newEntryDeadline().call() + 60 * 60 * 24 * 7 * 26  # + 26 weeks

MERKLE_DISTRIBUTOR_ADDRESSES = config("MERKLE_DISTRIBUTOR_ADDRESSES", cast=Csv())

with open("abi/MerkleDistributor.json") as json_data:
    MERKLE_DISTRIBUTOR_ABI = json.load(json_data)["abi"]
MERKLE_DISTRIBUTORS_WSS = [
    WEB3_WSS.eth.contract(address=address, abi=MERKLE_DISTRIBUTOR_ABI) for address in MERKLE_DISTRIBUTOR_ADDRESSES
]

INDEXER_BLOCKS_PER_CALL = 5
INDEXER_STATS_BLOCKS_PER_CALL = 6400
INDEXER_SLEEP_BETWEEN_CALL = config("INDEXER_SLEEP_BETWEEN_CALL", default=5.0, cast=float)

# block to fee
FEE = OrderedDict({
    17543991: 0.225,
    0: 0.0,
})

# Will be used to flag the last position ID that get's 15% apy
LAST_POSITION_ID_FOR_15PERC_APY = config("LAST_POSITION_ID_FOR_15PERC_APY", cast=int, default=10000000000000)

# Protocols (from local csv file, kept in memory)
with open("./meta/protocols.csv", newline="") as csv_file:
    PROTOCOLS_CSV = list(csv.DictReader(csv_file))

    # Checksum addresses
    PROTOCOLS_CSV = [{
        **entry,
        "agent": Web3.toChecksumAddress(entry["agent"]),
        "premium_float": float(entry["premium"].replace("%", "")) / 100 if len(entry["premium"]) != 0 else None
    } for entry in PROTOCOLS_CSV]

# Protocols TVL history
with open("./meta/tvl_history.csv", newline="") as csv_file:
    TVL_HISTORY_CSV = list(csv.DictReader(csv_file))

    # Parse timestamps as ints
    TVL_HISTORY_CSV = [{**entry, "timestamp": int(entry["timestamp"])} for entry in TVL_HISTORY_CSV]

    # Sort descending by timestamp all entries
    TVL_HISTORY_CSV = sorted(TVL_HISTORY_CSV, key=lambda x: x["timestamp"], reverse=True)

    # Process the CSV into a dict with the following structure
    # {
    #   "PROTOCOL_ID": [
    #    {
    #      'timestamp': 1234567,
    #      'value': 500_000
    #    },
    #    {
    #      'timestamp': 1234568,
    #      'value': 525_000
    #    }
    #   ]
    # }
    HARDCODED_TVL_PROTOCOLS = {}
    for entry in TVL_HISTORY_CSV:
        HARDCODED_TVL_PROTOCOLS.setdefault(entry["id"], []).append(
            {"timestamp": int(entry["timestamp"]), "value": int(float(entry["tvl"].replace(",", "")) * (10**6))}
        )

MAPLE_APY_HISTORY_CSV_NAME = config("MAPLE_APY_HISTORY_CSV_NAME", default="maple.csv")
# [
#    {
#      'timestamp': 1234567,
#      'value': 0.0521
#    },
#    {
#      'timestamp': 1234568,
#      'value': 0.0621
#    },
# ]
APY_HISTORY_MAPLE = []
if os.path.exists(MAPLE_APY_HISTORY_CSV_NAME):
    with open(MAPLE_APY_HISTORY_CSV_NAME, newline="\n") as csv_file:
        MAPLE_APY_HISTORY_CSV = list(csv.DictReader(csv_file))

        for entry in MAPLE_APY_HISTORY_CSV:
            APY_HISTORY_MAPLE.append(
                {"timestamp": int(entry["timestamp"]), "value": float(entry["apy"])}
            )
else:
    # Write CSV header if file is new
    with open(MAPLE_APY_HISTORY_CSV_NAME, "w+") as csv_file:
        csv_file.write("block,timestamp,apy\n")


USDC_INCENTIVES_PROTOCOL = "0x47a46b3628edc31155b950156914c27d25890563476422202887ed4298fc3c98"

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


# Redirect INFO+ logs to console and output.log
file_handler = ConcurrentRotatingFileHandler("output.log", "a", 20 * 1024 * 1024, 20)
file_handler.setLevel("INFO")
file_handler.setFormatter(verbose_formatter)

console_handler = StreamHandler()
console_handler.setLevel("INFO")
console_handler.setFormatter(verbose_formatter)

# Redirect DEBUG+ logs to separate file
debug_file_handler = ConcurrentRotatingFileHandler("debug_output.log", "a", 20 * 1024 * 1024, 20)
debug_file_handler.setLevel("DEBUG")
debug_file_handler.setFormatter(verbose_formatter)

logger.handlers = []
logger.addHandler(console_handler)
logger.addHandler(file_handler)
logger.addHandler(debug_file_handler)

# SENTRY
# ------------------------------------------------------------------------------
SENTRY_DSN = config("SENTRY_DSN")
SENTRY_ENVIRONMENT = config("SENTRY_ENVIRONMENT")

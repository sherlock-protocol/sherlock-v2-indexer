import csv
import json
import os
from collections import OrderedDict
from datetime import datetime
from logging import Formatter, StreamHandler, getLogger

from concurrent_log_handler import ConcurrentRotatingFileHandler
from decouple import Csv, config
from sqlalchemy import create_engine
from web3 import Web3, WebsocketProvider
from web3.middleware import geth_poa_middleware

API_HOST = config("API_HOST", default="127.0.0.1")
API_PORT = config("API_PORT", default=5000, cast=int)
API_DEBUG = config("API_DEBUG", default=False, cast=bool)

DB_USER = config("DB_USER")
DB_PASS = config("DB_PASS")
DB_PORT = config("DB_PORT")
if os.environ.get('PYTEST_CURRENT_TEST'):
    DB_NAME = config("DB_NAME_TEST", default='indexer_test')
else:
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

# Events Cache URL
EVENTS_CACHE_URL = config("EVENTS_CACHE_URL")

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
INDEXER_START_BLOCK = config("INDEXER_START_BLOCK", cast=int, default=14310144)

# Will be used to flag the last position ID that get's 15% apy
LAST_POSITION_ID_FOR_15PERC_APY = config("LAST_POSITION_ID_FOR_15PERC_APY", cast=int, default=10000000000000)

# Protocols (from local csv file, kept in memory)
with open("./meta/protocols.csv", newline="") as csv_file:
    PROTOCOLS_CSV = list(csv.DictReader(csv_file))

    # Remove as it conflicts with "premium" when rendering /protocols
    for entry in PROTOCOLS_CSV:
        del entry["premium"]

    # Checksum addresses
    PROTOCOLS_CSV = [
        {
            **entry,
            "agent": Web3.toChecksumAddress(entry["agent"]),
            "premium_float": float(entry["premium"].replace("%", "")) / 100 if len(entry["premium"]) != 0 else None,
        }
        for entry in PROTOCOLS_CSV
    ]

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
            APY_HISTORY_MAPLE.append({"timestamp": int(entry["timestamp"]), "value": float(entry["apy"])})
else:
    # Write CSV header if file is new
    with open(MAPLE_APY_HISTORY_CSV_NAME, "w+") as csv_file:
        csv_file.write("block,timestamp,apy\n")


USDC_INCENTIVES_PROTOCOL = "0x47a46b3628edc31155b950156914c27d25890563476422202887ed4298fc3c98"

# EXTERNAL COVERAGE
# ------------------------------------------------------------------------------
HARDCODED_TOTAL_EXTERNAL_COVERAGE = OrderedDict(
    {
        datetime(2022, 11, 17): 8_237_500,
        datetime(2022, 12, 18): 7_512_500,
        datetime(2023, 1, 20): 7_075_875,
        datetime(2023, 2, 23): 8_657_500,
        datetime(2023, 3, 22): 4_293_075,
        datetime(2023, 4, 21): 4_850_000,
    }
)
HARDCODED_TOTAL_EXTERNAL_COVERAGE_END_DATE = datetime(2023, 5, 19)
HARDCODED_PROTOCOL_EXTERNAL_COVERAGE = {
    # Squeeth by Opyn
    "0x99b8883ea932491b57118762f4b507ebcac598bee27b98f443c06d889237d9a4": OrderedDict(
        {
            datetime(2023, 5, 19): 750_000,
            datetime(2023, 10, 20): 510_000,
            datetime(2023, 11, 20): 422_534,
            datetime(2024, 6, 17): 651_359,
        }
    ),
    # Sentiment
    "0x5af5b22283e35ef9d9d4a32753014cdc40fd7a5a5d920d83d2c1e901c10a0a7c": OrderedDict(
        {
            datetime(2023, 5, 19): 750_000,
        }
    ),
    # Lyra Newport
    "0x60ad05ee84333895c49c1ea7890a2576925e4e809b716b715abc37865c554309": OrderedDict(
        {
            datetime(2023, 5, 19): 750_000,
            datetime(2023, 6, 19): 375_000,
            datetime(2023, 11, 20): 420_000,
        }
    ),
    # Perennial
    "0x60dee29c004aa336ef555e6cfce86038a3e604dbf18852d98310112964b12048": OrderedDict(
        {
            datetime(2023, 5, 19): 750_000,
            datetime(2023, 10, 20): 510_000,
            datetime(2023, 11, 20): 422_534,
            datetime(2024, 6, 17): 651_359,
        }
    ),
    # LiquiFi
    "0xeae496e133d5a5216d30ca085cc88546283c6567e787523dcd439c33d09f9862": OrderedDict(
        {
            datetime(2023, 5, 19): 750_000,
            datetime(2023, 10, 20): 510_000,
            datetime(2023, 11, 20): 422_534,
        }
    ),
    # Lyra Avalon
    "0x9c832ff12f1059a111aeb390ae646e686435ffa13c2bdc61d499758b85c1a716": OrderedDict(
        {
            datetime(2023, 5, 19): 750_000,
        }
    ),
    # Buffer Finance
    "0x850c0962cff040fb352c8273518960d0c5ce60c961a1a01180a51e05fcf9403e": OrderedDict(
        {
            datetime(2023, 5, 19): 691_959,
        }
    ),
    # Hook
    "0x7141e52f1187d2baa72e449b5470b3cd2b2cfe77ccade306ff9bcadf941a7a8d": OrderedDict(
        {
            datetime(2023, 5, 19): 93_750,
            datetime(2023, 11, 20): 105_000,
        }
    ),
    # Holyheld
    "0xb544040099f1bc2a2592d756f8b36e66e213049b312844459226271402cd854c": OrderedDict(
        {
            datetime(2023, 5, 19): 18_750,
        }
    ),
    # Union Finance
    "0xd883fd72e18db3cd7aeadfb568489425d6b342ed705040c200f145caa73ce603": OrderedDict(
        {
            datetime(2023, 5, 19): 75_000,
            datetime(2023, 7, 20): 33_750,
            datetime(2023, 8, 20): 34_997,
            datetime(2023, 9, 20): 31_807,
            datetime(2023, 11, 20): 35_624,
            datetime(2024, 3, 24): 43_459,
            datetime(2024, 6, 9): 126_000,
        }
    ),
    # OpenQ
    "0xd55fb2e557617b0f82ec70e70db577fa9aa52212b4b539d4ed5b947f08d7d23f": OrderedDict(
        {
            datetime(2023, 5, 19): 67_125,
        }
    ),
    # Ajna
    "0x311378546a9b2d446c7eef43258f16d09348109c57b9fc6220adcea57014c204": OrderedDict(
        {
            datetime(2023, 7, 20): 750_000,
            datetime(2023, 10, 20): 510_000,
            datetime(2023, 11, 20): 422_534,
        }
    ),
    # Teller
    "0x34a4bbea85db417e21bb6e43a826a4a25c5f999a1b18aa2c32ff1b58a3f181f9": OrderedDict(
        {
            datetime(2023, 7, 20): 112_500,
            datetime(2023, 9, 20): 487_500,
            datetime(2023, 11, 20): 422_534,
            datetime(2024, 3, 29): 2_624_000,
            datetime(2024, 6, 10): 2_848_000,
        }
    ),
    # Arcadia
    "0x364b312cb168b38be075f9a08d64d767290ee94c117be39b2916328be8193b6c": OrderedDict(
        {
            datetime(2024, 4, 4): 750_000,
        }
    ),
}
HARDCODED_PROTOCOL_EXTERNAL_COVERAGE_END_DATE = datetime(2024, 7, 2)

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

import logging
from typing import Optional

from web3.contract import Contract
from web3.exceptions import BadFunctionCallOutput

from settings import STRATEGY_ABI, WEB3_WSS

logger = logging.getLogger(__name__)


class Strategy:
    address: str
    name: str
    contract: Contract = None

    def __init__(self, address, name) -> None:
        self.address = address
        self.name = name

        self.connect()

    def connect(self) -> bool:
        if self.contract:
            return True

        try:
            self.contract = WEB3_WSS.eth.contract(address=self.address, abi=STRATEGY_ABI)
            return True
        except Exception as e:
            logger.exception(e)
            return False

    def __str__(self) -> str:
        return f"Strategy {self.name} @ {self.address}"

    def get_balance(self, block: int) -> Optional[int]:
        if not self.connect():
            return None

        logger.debug("Fetching %s balance" % self)

        try:
            balance = self.contract.functions.balanceOf().call(block_identifier=block)
            logger.info("%s balance is %s" % (self, balance))

            return balance
        except BadFunctionCallOutput as e:
            # Skip logging the entire stack as an error, when the exception is related
            # to the strategy contract not being deployed yet.
            logger.debug(e, exc_info=True)
            logger.debug("%s is not yet deployed." % self)

            return None
        except Exception as e:
            logger.exception(e)
            return None


class Strategies:
    AAVE = Strategy(address="0xE3C37e951F1404b162DFA71A13F0c99c9798Db82", name="Aave")
    COMPOUND = Strategy(address="0x8AEA96da625791103a29a16C06c5cfC8B25f6832", name="Compound")
    EULER = Strategy(address="0x9a902e8Aae5f1aB423c7aFB29C0Af50e0d3Fea7e", name="Euler")

    ALL = [AAVE, COMPOUND, EULER]

    @classmethod
    def get(self, address):
        """Fetch a strategy by its address.j

        Args:
            address (_type_): Strategy address

        Returns:
            Strategy: Strategy instance
        """
        for item in self.ALL:
            if item.address == address:
                return item

        return None

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
    AAVE = Strategy(address="0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E", name="Aave")
    COMPOUND = Strategy(address="0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8", name="Compound")

    ALL = [AAVE, COMPOUND]

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

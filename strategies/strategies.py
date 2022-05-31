import logging
from typing import Optional

from web3.contract import Contract

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
        except Exception as e:
            logger.exception(e)
            return None


class Strategies:
    AAVE = Strategy(address="0xab9c505c21b59D7263e8409fB618262e9871b4D2", name="Aave")
    COMPOUND = Strategy(address="0xab9c505c21b59D7263e8409fB618262e9871b4D2", name="Compound")
    EULER = Strategy(address="0xab9c505c21b59D7263e8409fB618262e9871b4D2", name="Euler")
    TRUEFI = Strategy(address="0xab9c505c21b59D7263e8409fB618262e9871b4D2", name="TrueFi")
    MAPLE = Strategy(address="0xab9c505c21b59D7263e8409fB618262e9871b4D2", name="Maple")

    ALL = [AAVE, COMPOUND, EULER, TRUEFI, MAPLE]

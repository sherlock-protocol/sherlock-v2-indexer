import logging

from sqlalchemy import Column, Integer, Text
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base

logger = logging.getLogger(__name__)


class StrategyBalance(Base):
    __tablename__ = "strategy_balances"

    id = Column(Integer, primary_key=True)
    address = Column(Text, nullable=False)
    value = Column(NUMERIC(78), nullable=False)
    timestamp = Column(TIMESTAMP, nullable=False)
    block = Column(Integer, nullable=False)

    @staticmethod
    def insert(session, block, timestamp, address, value):
        new_balance = StrategyBalance()
        new_balance.address = address
        new_balance.value = value
        new_balance.block = block
        new_balance.value = value

        session.add(new_balance)

    def to_dict(self):
        return {
            "address": self.address,
            "value": self.value,
            "timestamp": int(self.timestamp.timestamp()),
            "block": self.block,
        }

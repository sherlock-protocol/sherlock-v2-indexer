import logging

from sqlalchemy import Column, Integer, String
from sqlalchemy.dialects.postgresql import JSON, NUMERIC, TIMESTAMP

from models.base import Base

logger = logging.getLogger(__name__)


class Airdrop(Base):
    __tablename__ = "airdrops"

    id = Column(Integer, primary_key=True)
    index = Column(Integer, nullable=False)
    address = Column(String(42), nullable=False)
    amount = Column(NUMERIC(78), nullable=False)
    proof = Column(JSON, nullable=False)
    claimed_at_block = Column(Integer, nullable=True)
    claimed_at_timestamp = Column(TIMESTAMP, nullable=True)

    @staticmethod
    def insert(session, index, address, amount, proof):
        logger.info("Creating new Airdrop entry index %d for %s in amount of %s", index, address, amount)

        s = Airdrop()
        s.index = index
        s.address = address
        s.amount = amount
        s.proof = proof

        session.add(s)

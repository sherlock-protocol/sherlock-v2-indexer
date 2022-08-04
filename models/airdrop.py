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
    token_symbol = Column(String(10), nullable=False)
    contract_address = Column(String(42), nullable=False)
    proof = Column(JSON, nullable=False)
    claimed_at_block = Column(Integer, nullable=True)
    claimed_at_timestamp = Column(TIMESTAMP, nullable=True)

    @staticmethod
    def get(session, address):
        return session.query(Airdrop).filter_by(address=address).first()

    @staticmethod
    def insert(session, index, address, amount, token_symbol, contract_address, proof):
        logger.info(
            "Creating new Airdrop entry index %d for %s in amount of %s %s", index, address, amount, token_symbol
        )

        s = Airdrop()
        s.index = index
        s.address = address
        s.amount = amount
        s.token_symbol = token_symbol
        s.contract_address = contract_address
        s.proof = proof

        session.add(s)

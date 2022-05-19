import logging
from datetime import datetime

from sqlalchemy import Column, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base

logger = logging.getLogger(__name__)


class Claim(Base):
    __tablename__ = "claims"

    id = Column(Integer, primary_key=True)
    protocol_id = Column(Integer, ForeignKey("protocols.id"), nullable=False)
    created_at = Column(TIMESTAMP, nullable=False)
    amount = Column(NUMERIC(78), nullable=False)
    status = Column(Integer, default=0)

    @staticmethod
    def insert(session, id, protocol_id, amount, timestamp):
        logger.info("Creating claim for protocol %s in amount of %s", protocol_id, amount)
        created_at = datetime.fromtimestamp(timestamp)

        claim = Claim()
        claim.id = id
        claim.protocol_id = protocol_id
        claim.amount = amount
        claim.created_at = created_at
        claim.status = 0

        session.add(claim)

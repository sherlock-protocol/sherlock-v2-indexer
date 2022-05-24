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
    exploit_started_at = Column(TIMESTAMP, nullable=True)
    amount = Column(NUMERIC(78), nullable=False)
    status = Column(Integer, default=0)
    timestamp = Column(TIMESTAMP, nullable=False)

    @staticmethod
    def insert(session, id, protocol_id, amount, exploit_started_at_timestamp, created_at_timestamp):
        logger.info("Creating claim for protocol %s in amount of %s", protocol_id, amount)
        exploit_started_at = datetime.fromtimestamp(exploit_started_at_timestamp)
        created_at = datetime.fromtimestamp(created_at_timestamp)

        claim = Claim()
        claim.id = id
        claim.protocol_id = protocol_id
        claim.amount = amount
        claim.explot_started_at = exploit_started_at
        claim.status = 0
        claim.timestamp = created_at

        session.add(claim)

    @staticmethod
    def update_status(session, id, status):
        logger.info("Updating claim %s to status: %s", id, status)

        claim = session.query(Claim).get(id)

        if not claim:
            logger.info("Claim with id %s not found!", id)
            return

        claim.status = status

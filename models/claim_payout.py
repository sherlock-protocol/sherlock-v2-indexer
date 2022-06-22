import json
import logging
from datetime import datetime

from sqlalchemy import Column, ForeignKey, Integer, Text
from sqlalchemy.dialects.postgresql import TIMESTAMP

from models.base import Base

logger = logging.getLogger(__name__)


class ClaimPayout(Base):
    __tablename__ = "claim_payouts"

    id = Column(Integer, primary_key=True)
    claim_id = Column(Integer, ForeignKey("claims.id"), nullable=False)
    tx_hash = Column(Text, nullable=False)
    timestamp = Column(TIMESTAMP, nullable=False)

    @staticmethod
    def insert(session, claim_id, tx_hash, timestamp):
        logger.info("Creating claim payout for claim %s", claim_id)

        payout = ClaimPayout()
        payout.claim_id = claim_id
        payout.tx_hash = tx_hash
        payout.timestamp = datetime.fromtimestamp(timestamp)

        session.add(payout)

    def to_dict(self):
        """Converts object to dict.
        @return: dict
        """
        d = {}
        for column in self.__table__.columns:
            data = getattr(self, column.name)
            if column.name in ["timestamp"] and data is not None:
                d[column.name] = int(data.timestamp())
                continue
            d[column.name] = data
        return d

    def to_json(self):
        """Converts object to JSON.
        @return: JSON data
        """
        return json.dumps(self.to_dict(), default=str)

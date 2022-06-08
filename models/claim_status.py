import logging
import json
from datetime import datetime
from time import time
from sqlalchemy import Column, ForeignKey, Integer, Text
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base

logger = logging.getLogger(__name__)


class ClaimStatus(Base):
    __tablename__ = "claim_status"

    id = Column(Integer, primary_key=True)
    claim_id = Column(Integer, ForeignKey("claims.id"), nullable=False)
    status = Column(Integer, default=0)
    timestamp = Column(TIMESTAMP, nullable=False)

    @staticmethod
    def insert(session, claim_id, status, timestamp):
        claim_status = ClaimStatus()
        claim_status.claim_id = claim_id
        claim_status.status = status
        claim_status.timestamp = datetime.fromtimestamp(timestamp)

        session.add(claim_status)

    @staticmethod
    def get_claim_status(session, claim_id):
        return (
            session.query(ClaimStatus)
            .filter_by(claim_id=claim_id)
            .order_by(ClaimStatus.timestamp.desc())
            .order_by(ClaimStatus.id.desc())
            .all()
        )

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

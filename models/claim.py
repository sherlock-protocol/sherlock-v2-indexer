import json
import logging
from datetime import datetime

from sqlalchemy import Column, ForeignKey, Integer, Text, desc
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base
from models.claim_status import ClaimStatus

logger = logging.getLogger(__name__)


class Claim(Base):
    __tablename__ = "claims"

    id = Column(Integer, primary_key=True)
    protocol_id = Column(Integer, ForeignKey("protocols.id"), nullable=False)
    initiator = Column(Text, nullable=False)
    receiver = Column(Text, nullable=False)
    exploit_started_at = Column(TIMESTAMP, nullable=True)
    amount = Column(NUMERIC(78), nullable=False)
    resources_link = Column(Text, nullable=True)
    timestamp = Column(TIMESTAMP, nullable=False)

    @staticmethod
    def insert(
        session,
        id,
        protocol_id,
        initiator,
        receiver,
        amount,
        resources_link,
        exploit_started_at_timestamp,
        created_at_timestamp,
    ):
        logger.info("Creating claim for protocol %s in amount of %s", protocol_id, amount)
        exploit_started_at = datetime.fromtimestamp(exploit_started_at_timestamp)
        created_at = datetime.fromtimestamp(created_at_timestamp)

        claim = Claim()
        claim.id = id
        claim.protocol_id = protocol_id
        claim.initiator = initiator
        claim.receiver = receiver
        claim.amount = amount
        claim.resources_link = resources_link
        claim.exploit_started_at = exploit_started_at
        claim.timestamp = created_at

        session.add(claim)

    @staticmethod
    def get_active_claim_by_protocol(session, protocol_id):
        claim = (
            session.query(Claim)
            .join(ClaimStatus, Claim.id == ClaimStatus.claim_id)
            .where(Claim.protocol_id == protocol_id)
            .order_by(desc(Claim.id), desc(ClaimStatus.id))
            .one_or_none()
        )

        return claim

    def to_dict(self):
        """Converts object to dict.
        @return: dict
        """
        d = {}
        for column in self.__table__.columns:
            data = getattr(self, column.name)
            if column.name in ["exploit_started_at", "timestamp"] and data is not None:
                d[column.name] = int(data.timestamp())
                continue
            d[column.name] = data
        return d

    def to_json(self):
        """Converts object to JSON.
        @return: JSON data
        """
        return json.dumps(self.to_dict(), default=str)

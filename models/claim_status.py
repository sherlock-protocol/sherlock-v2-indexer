import json
import logging
from datetime import datetime
from enum import Enum

from sqlalchemy import Column, ForeignKey, Integer, Text
from sqlalchemy.dialects.postgresql import TIMESTAMP

from models.base import Base

logger = logging.getLogger(__name__)


class ClaimStatus(Base):
    __tablename__ = "claim_status"

    class Status(Enum):
        # Claim is created, SPCC is able to set state to valid
        SpccPending = 1
        # Final state, claim is valid
        SpccApproved = 2
        # Claim denied by SPCC, claim can be escalated within 4 weeks
        SpccDenied = 3
        # Price is proposed but not escalated
        UmaPriceProposed = 4
        # Price is proposed, callback received, ready to submit dispute
        ReadyToProposeUmaDispute = 5
        # Escalation is done, waiting for confirmation
        UmaDisputeProposed = 6
        # Claim is escalated, in case Spcc denied or didn't act within 7 days.
        UmaPending = 7
        # Final state, claim is valid, claim can be enacted after 1 day, umaHaltOperator has 1 day to change to denied
        UmaApproved = 8
        # Final state, claim is invalid
        UmaDenied = 9
        # UMAHO can halt claim if state is UmaApproved
        Halted = 10
        # Claim is removed by protocol agent
        Cleaned = 11
        # Protocol agent executed the payout
        PaidOut = 12

    id = Column(Integer, primary_key=True)
    claim_id = Column(Integer, ForeignKey("claims.id"), nullable=False)
    status = Column(Integer, nullable=False)
    tx_hash = Column(Text, nullable=False)
    timestamp = Column(TIMESTAMP, nullable=False)

    @staticmethod
    def insert(session, claim_id, status, tx_hash, timestamp):
        claim_status = ClaimStatus()
        claim_status.claim_id = claim_id
        claim_status.status = status
        claim_status.tx_hash = tx_hash
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

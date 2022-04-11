from datetime import datetime

from sqlalchemy import Column, ForeignKey, Integer, UniqueConstraint
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base


class ProtocolCoverage(Base):
    __tablename__ = "protocols_coverages"
    __table_args__ = (UniqueConstraint("protocol_id", "coverage_amount", "coverage_amount_set_at"),)

    id = Column(Integer, primary_key=True)
    protocol_id = Column(Integer, ForeignKey("protocols.id"), nullable=False)
    coverage_amount = Column(NUMERIC(78), nullable=False)
    coverage_amount_set_at = Column(TIMESTAMP, nullable=False)
    claimable_until = Column(TIMESTAMP, nullable=True)

    @staticmethod
    def insert(session, protocol_id, coverage_amount, timestamp):
        coverage_amount_set_at = datetime.fromtimestamp(timestamp)

        protocol_coverage = ProtocolCoverage()
        protocol_coverage.protocol_id = protocol_id
        protocol_coverage.coverage_amount = coverage_amount
        protocol_coverage.coverage_amount_set_at = coverage_amount_set_at

        session.add(protocol_coverage)

    def to_dict(self):
        return {
            "coverage_amount": self.coverage_amount,
            "coverage_amount_set_at": int(self.coverage_amount_set_at.timestamp())
            if self.coverage_amount_set_at
            else None,
        }

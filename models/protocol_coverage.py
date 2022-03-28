from datetime import datetime

from sqlalchemy import Column, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base


class ProtocolCoverage(Base):
    __tablename__ = "protocols_coverages"

    id = Column(Integer, primary_key=True)
    protocol_id = Column(Integer, ForeignKey("protocols.id"), nullable=False)
    coverage_amount = Column(NUMERIC(78), nullable=False)
    coverage_amount_set_at = Column(TIMESTAMP, nullable=False)

    @staticmethod
    def insert(session, protocol_id, coverage_amount, timestamp):
        coverage_amount_set_at = datetime.fromtimestamp(timestamp)

        # Check if coverage amount change has already been saved
        already_exists = (
            session.query(ProtocolCoverage)
            .filter_by(
                protocol_id=protocol_id, coverage_amount=coverage_amount, coverage_amount_set_at=coverage_amount_set_at
            )
            .one_or_none()
        )

        if already_exists:
            return

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

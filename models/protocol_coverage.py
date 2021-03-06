import logging
from datetime import datetime, timedelta

from sqlalchemy import Column, ForeignKey, Integer, UniqueConstraint
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base

logger = logging.getLogger(__name__)


class ProtocolCoverage(Base):
    __tablename__ = "protocols_coverages"
    __table_args__ = (UniqueConstraint("protocol_id", "coverage_amount", "coverage_amount_set_at"),)

    id = Column(Integer, primary_key=True)
    protocol_id = Column(Integer, ForeignKey("protocols.id"), nullable=False)
    coverage_amount = Column(NUMERIC(78), nullable=False)
    coverage_amount_set_at = Column(TIMESTAMP, nullable=False)
    claimable_until = Column(TIMESTAMP, nullable=True)

    @staticmethod
    def get_protocol_coverages(session, protocol_id):
        return (
            session.query(ProtocolCoverage)
            .filter_by(protocol_id=protocol_id)
            .order_by(ProtocolCoverage.coverage_amount_set_at.desc())
            .limit(2)
            .all()
        )

    @staticmethod
    def insert(session, protocol_id, coverage_amount, timestamp):
        logger.info("Creating protocol coverage in amount of %s for protocol #%s", coverage_amount, protocol_id)
        coverage_amount_set_at = datetime.fromtimestamp(timestamp)

        protocol_coverage = ProtocolCoverage()
        protocol_coverage.protocol_id = protocol_id
        protocol_coverage.coverage_amount = coverage_amount
        protocol_coverage.coverage_amount_set_at = coverage_amount_set_at

        session.add(protocol_coverage)

    @staticmethod
    def update(session, protocol_id, new_coverage_amount, timestamp):
        updated_at = datetime.fromtimestamp(timestamp)

        # Fetch current (and previous, if exists) coverage amounts
        existing_coverage_amounts = ProtocolCoverage.get_protocol_coverages(session, protocol_id)

        if new_coverage_amount == 0:
            logger.info("Protocol %s coverage has been removed.", protocol_id)
            # Protocol has been removed, but it still has
            # a window of 7 more days to submit a claim.

            # Set claimable_until amounts
            for item in existing_coverage_amounts:
                item.claimable_until = updated_at + timedelta(days=7)
        else:
            # Protocol's coverage amount has changed.
            if len(existing_coverage_amounts) == 2:
                # Previous coverage is no longer available for claiming
                existing_coverage_amounts[1].claimable_until = updated_at

            ProtocolCoverage.insert(session, protocol_id, new_coverage_amount, timestamp)

    def to_dict(self):
        return {
            "coverage_amount": self.coverage_amount,
            "coverage_amount_set_at": int(self.coverage_amount_set_at.timestamp())
            if self.coverage_amount_set_at
            else None,
            "claimable_until": int(self.claimable_until.timestamp()) if self.claimable_until else None,
        }

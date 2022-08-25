import logging
from datetime import datetime

from sqlalchemy import Column, ForeignKey, Integer, func
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

import settings
from models.base import Base

logger = logging.getLogger(__name__)


class ProtocolPremium(Base):
    __tablename__ = "protocols_premiums"

    id = Column(Integer, primary_key=True)
    protocol_id = Column(Integer, ForeignKey("protocols.id"), nullable=False)
    premium = Column(NUMERIC(78), nullable=False)
    premium_set_at = Column(TIMESTAMP, nullable=False)

    @staticmethod
    def insert(session, protocol_id, premium, timestamp):
        logger.info("Creating protocol premium in amount of %s for protocol %s", premium, protocol_id)
        premium_set_at = datetime.fromtimestamp(timestamp)

        # Check if premium change has already been saved
        already_exists = (
            session.query(ProtocolPremium)
            .filter_by(protocol_id=protocol_id, premium=premium, premium_set_at=premium_set_at)
            .one_or_none()
        )

        if already_exists:
            return

        protocol_premium = ProtocolPremium()
        protocol_premium.protocol_id = protocol_id
        protocol_premium.premium = premium
        protocol_premium.premium_set_at = premium_set_at

        session.add(protocol_premium)

    @staticmethod
    def get_sum_of_premiums(session):
        # Sums up the latest premium of each protocol.
        return (
            session.query(func.sum(ProtocolPremium.premium))
            .filter(
                ProtocolPremium.id.in_(
                    session.query(ProtocolPremium.id)
                    .filter(ProtocolPremium.protocol_id != settings.USDC_INCENTIVES_PROTOCOL)
                    .distinct(ProtocolPremium.protocol_id)
                    .order_by(ProtocolPremium.protocol_id, ProtocolPremium.premium_set_at.desc())
                )
            )
            .scalar()
        )

    @staticmethod
    def get_usdc_incentive_premiums(session):
        # Retrieve the latest premium paid by the USDC incentive protocol
        # Could return None
        return (
            session.query(ProtocolPremium.premium)
            .filter(ProtocolPremium.protocol_id == settings.USDC_INCENTIVES_PROTOCOL)
            .order_by(ProtocolPremium.premium_set_at.desc())
            .limit(1)
            .scalar()
        )

    def to_dict(self):
        return {
            "premium": self.premium,
            "premium_set_at": int(self.premium_set_at.timestamp()) if self.premium_set_at else None,
        }

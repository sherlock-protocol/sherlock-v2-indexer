import logging
from datetime import datetime

from sqlalchemy import Column, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP
from sqlalchemy.orm import relationship

from models.base import Base
from models.protocol import Protocol

logger = logging.getLogger(__name__)


class ProtocolNonstakers(Base):
    __tablename__ = "protocols_nonstakers"

    id = Column(Integer, primary_key=True)
    protocol_id = Column(Integer, ForeignKey("protocols.id"), nullable=False)
    nonstakers = Column(NUMERIC(78), nullable=False)
    nonstakers_set_at = Column(TIMESTAMP, nullable=False)

    protocol = relationship(Protocol)

    @staticmethod
    def insert(session, protocol_id, nonstakers, timestamp):
        logger.info("Creating protocol nonstakers in amount of %s for protocol %s", nonstakers, protocol_id)
        nonstakers_set_at = datetime.fromtimestamp(timestamp)

        # Check if nonstakers change has already been saved
        already_exists = (
            session.query(ProtocolNonstakers)
            .filter_by(protocol_id=protocol_id, nonstakers=nonstakers, nonstakers_set_at=nonstakers_set_at)
            .one_or_none()
        )

        if already_exists:
            return

        protocol_nonstakers = ProtocolNonstakers()
        protocol_nonstakers.protocol_id = protocol_id
        protocol_nonstakers.nonstakers = nonstakers
        protocol_nonstakers.nonstakers_set_at = nonstakers_set_at

        session.add(protocol_nonstakers)

    def to_dict(self):
        return {
            "nonstakers": self.nonstakers,
            "nonstakers_set_at": int(self.nonstakers_set_at.timestamp()) if self.nonstakers_set_at else None,
        }

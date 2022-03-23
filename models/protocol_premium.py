from sqlalchemy import Column, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base


class ProtocolPremium(Base):
    __tablename__ = "protocols_premiums"

    id = Column(Integer, primary_key=True, default=1)
    protocol_id = Column(Integer, ForeignKey("protocols.id"), nullable=False)
    premium = Column(NUMERIC(78), nullable=False)
    premium_set_at = Column(TIMESTAMP, nullable=False)

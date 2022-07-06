import logging
from datetime import datetime

from sqlalchemy import Column, Integer, Text, text
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base

logger = logging.getLogger(__name__)


class Protocol(Base):
    __tablename__ = "protocols"

    id = Column(Integer, primary_key=True)
    bytes_identifier = Column(Text, nullable=False, unique=True)
    agent = Column(Text, nullable=False)
    coverage_ended_at = Column(TIMESTAMP)
    tvl = Column(NUMERIC(78), nullable=True)

    @staticmethod
    def parse_bytes_id(bytes):
        return "0x" + bytes.hex()

    @staticmethod
    def get(session, bytes_id):
        return session.query(Protocol).filter_by(bytes_identifier=bytes_id).one_or_none()

    @staticmethod
    def insert(session, bytes_identifier):
        logger.info("Adding protocol %s", bytes_identifier)
        protocol = Protocol.get(session, bytes_identifier)

        if not protocol:
            protocol = Protocol()
            protocol.bytes_identifier = bytes_identifier
            # Protocol agent is not available in the ProtocolAdded event,
            # but a ProtocolAgentTransfer event is emitted in the same block
            # which will update this instance to it's correct addres.
            protocol.agent = "0x0"
            session.add(protocol)
        else:
            logger.info("Re-enabling inactive protocol")
            # When a protocol is re-added, we should only mark the protocol
            # as active. The other events: ProtocolAgentTransfer, ProtocolUpdated
            # and protocolPremiumChanged will update this instance to hold
            # the new values.
            protocol.coverage_ended_at = None

    @staticmethod
    def update_agent(session, bytes_identifier, agent):
        logger.info("Updating agent to %s for protocol %s", agent, bytes_identifier)
        protocol = Protocol.get(session, bytes_identifier)
        if not protocol:
            logger.error("Protocol %s not found!", bytes_identifier)
            return

        protocol.agent = agent

    @staticmethod
    def remove(session, bytes_identifier, timestamp):
        logger.info("Removing protocol %s", bytes_identifier)
        protocol = Protocol.get(session, bytes_identifier)
        if not protocol:
            return

        protocol.coverage_ended_at = datetime.fromtimestamp(timestamp)

    @staticmethod
    def get_sum_of_premiums(session):
        # Sums up the latest premium of each protocol.
        sql = text(
            """
            SELECT SUM(pc.premium) premiums
            FROM protocols_premiums pc
            INNER JOIN (
                SELECT p.id, MAX(pc.premium_set_at) timestamp
                FROM protocols p
                JOIN protocols_premiums pc ON pc.protocol_id = p.id
                WHERE p.coverage_ended_at IS NULL
                GROUP BY p.id
            ) max ON max.id = pc.protocol_id AND max.timestamp = pc.premium_set_at"""
        )

        result = session.execute(sql).first()

        return result["premiums"]

    def to_dict(self):
        return {
            "id": self.id,
            "bytes_identifier": self.bytes_identifier,
            "agent": self.agent,
            "coverage_ended_at": int(self.coverage_ended_at.timestamp()) if self.coverage_ended_at else None,
            "tvl": self.tvl,
        }

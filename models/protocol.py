from sqlalchemy import Column, Integer, Text
from sqlalchemy.dialects.postgresql import TIMESTAMP

from models.base import Base


class Protocol(Base):
    __tablename__ = "protocols"

    id = Column(Integer, primary_key=True)
    bytes_identifier = Column(Text, nullable=False, unique=True)
    agent = Column(Text, nullable=False)
    coverage_ended_at = Column(TIMESTAMP)

    @staticmethod
    def parse_bytes_id(bytes):
        return "0x" + bytes.hex()

    @staticmethod
    def get(session, bytes_id):
        return session.query(Protocol).filter_by(bytes_identifier=bytes_id).one_or_none()

    @staticmethod
    def insert(session, bytes_identifier):
        protocol = Protocol()
        protocol.bytes_identifier = bytes_identifier
        protocol.agent = "0x0"

        session.add(protocol)

    @staticmethod
    def update_agent(session, bytes_identifier, agent):
        protocol = Protocol.get(session, bytes_identifier)
        if not protocol:
            return

        protocol.agent = agent

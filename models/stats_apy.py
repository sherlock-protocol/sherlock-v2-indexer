import json
from datetime import datetime

from sqlalchemy import Column, Float, Integer
from sqlalchemy.dialects.postgresql import BIGINT, TIMESTAMP

from models.base import Base


class StatsAPY(Base):
    __tablename__ = "stats_apy"

    id = Column(BIGINT, primary_key=True)
    timestamp = Column(TIMESTAMP, nullable=False, default=datetime.min)
    value = Column(Float, nullable=False)
    premiums_apy = Column(Float, nullable=False)
    incentives_apy = Column(Float, nullable=False)
    block = Column(Integer, default=0)

    @staticmethod
    def insert(session, block, timestamp, total_apy, premiums_apy, incentives_apy):
        apy = StatsAPY()
        apy.timestamp = timestamp
        apy.value = total_apy
        apy.premiums_apy = premiums_apy
        apy.incentives_apy = incentives_apy
        apy.block = block

        session.add(apy)

    @staticmethod
    def find_all(session, offset, limit):
        return session.query(StatsAPY).order_by(StatsAPY.timestamp.asc()).offset(offset).limit(limit).all()

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

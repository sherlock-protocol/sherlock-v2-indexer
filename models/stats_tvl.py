import json
from datetime import datetime

from sqlalchemy import Column, Integer
from sqlalchemy.dialects.postgresql import TIMESTAMP, NUMERIC, BIGINT

from models.base import Base


class StatsTVL(Base):
    __tablename__ = "stats_tvl"

    id = Column(BIGINT, primary_key=True)
    timestamp = Column(TIMESTAMP, nullable=False, default=datetime.min)
    value = Column(NUMERIC(78), nullable=False)
    block = Column(Integer, default=0)

    @staticmethod
    def insert(session, block, timestamp, value):
        tvl = StatsTVL()
        tvl.timestamp = timestamp
        tvl.value = value
        tvl.block = block

        session.add(tvl)

    @staticmethod
    def find_all(session, offset, limit):
        return session.query(StatsTVL).order_by(StatsTVL.timestamp.asc()).offset(offset).limit(limit).all()

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

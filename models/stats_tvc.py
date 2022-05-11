import json
import logging
from datetime import datetime

from sqlalchemy import Column, Integer
from sqlalchemy.dialects.postgresql import BIGINT, NUMERIC, TIMESTAMP

from models.base import Base

logger = logging.getLogger(__name__)


class StatsTVC(Base):
    __tablename__ = "stats_tvc"

    id = Column(BIGINT, primary_key=True)
    timestamp = Column(TIMESTAMP, nullable=False, default=datetime.min)
    value = Column(NUMERIC(78), nullable=False)
    block = Column(Integer, default=0, nullable=False)

    @staticmethod
    def insert(session, block, timestamp, value):
        logger.info("Inserting TVC value of %s at %s", value, timestamp)
        tvc = StatsTVC()
        tvc.timestamp = timestamp
        tvc.value = value
        tvc.block = block

        session.add(tvc)

    @staticmethod
    def insert_from_delta(session, block, timestamp, delta):
        logger.info("Inserting TVC delta of %s at %s", delta, timestamp)
        last = session.query(StatsTVC).order_by(StatsTVC.timestamp.desc()).first()

        tvc = StatsTVC()
        tvc.timestamp = timestamp
        tvc.block = block

        if not last:
            tvc.value = delta
        else:
            tvc.value = last.value + delta

        session.add(tvc)

    @staticmethod
    def find_all(session, offset, limit):
        return session.query(StatsTVC).order_by(StatsTVC.timestamp.asc()).offset(offset).limit(limit).all()

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

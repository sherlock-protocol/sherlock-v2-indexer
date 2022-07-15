from sqlalchemy import Column, Integer, Text

from models.base import Base


class IntervalFunction(Base):
    __tablename__ = "interval_functions"

    name = Column(Text, primary_key=True)
    block_last_run = Column(Integer, default=0, server_default="0")

    @staticmethod
    def get(session, name):
        interval = session.query(IntervalFunction).filter_by(name=name).one_or_none()

        if not interval:
            interval = IntervalFunction(name=name)
            session.add(interval)

        return interval

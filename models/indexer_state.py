from datetime import datetime

from sqlalchemy import Column, Float, Integer
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

from models.base import Base


class IndexerState(Base):
    __tablename__ = "indexer_state"

    id = Column(Integer, primary_key=True, default=1)
    last_block = Column(Integer, nullable=False, default=0)
    last_time = Column(TIMESTAMP, nullable=False, default=datetime(1970, 1, 1, 1))
    last_stats_block = Column(Integer, nullable=False, default=0)
    last_stats_time = Column(TIMESTAMP, nullable=False, default=datetime(1970, 1, 1, 1))
    balance_factor = Column(NUMERIC(78, 70), nullable=False, default=0.0)
    apy = Column(Float, nullable=False, default=0.0)
    apy_50ms_factor = Column(NUMERIC(78, 70), nullable=False, default=0.0)  # TODO: Remove unused column

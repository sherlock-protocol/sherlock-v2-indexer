from datetime import datetime

from sqlalchemy import Column, Integer
from sqlalchemy.dialects.postgresql import TIMESTAMP

import settings
from models.base import Base


class StakingPositionsMeta(Base):
    __tablename__ = "staking_positions_meta"

    id = Column(Integer, primary_key=True, default=1)
    usdc_last_updated = Column(TIMESTAMP, nullable=False, default=datetime.min)
    usdc_last_updated_block = Column(Integer, nullable=False, default=0)

    @staticmethod
    def get(session):
        return session.query(StakingPositionsMeta).one()

    @staticmethod
    def update(session, block, balance_factor):
        timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]

        session.execute(
            "update staking_positions set usdc = usdc * :factor;",
            {"factor": balance_factor},
        )

        data = StakingPositionsMeta.get(session)
        data.usdc_last_updated = datetime.fromtimestamp(timestamp)
        data.usdc_last_updated_block = block

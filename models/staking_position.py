import json
from datetime import datetime, timedelta

from sqlalchemy import Column, String, desc
from sqlalchemy.dialects.postgresql import BIGINT, NUMERIC, TIMESTAMP

import settings
from models.base import Base


class StakingPositions(Base):
    __tablename__ = "staking_positions"

    id = Column(BIGINT, primary_key=True)
    owner = Column(String(42), nullable=False)
    lockup_end = Column(TIMESTAMP, nullable=False)
    usdc = Column(NUMERIC(78), nullable=False)
    sher = Column(NUMERIC(78), nullable=False)

    @staticmethod
    def get_for_factor(session):
        # Get biggest USDC position that is not about to expire
        safe_time = datetime.utcnow() + timedelta(days=7)

        return (
            session.query(StakingPositions)
            .filter(StakingPositions.lockup_end > safe_time)
            .order_by(desc(StakingPositions.usdc))
            .first()
        )

    @staticmethod
    def insert(session, block, id, owner):
        lockup_end = settings.CORE_WSS.functions.lockupEnd(id).call(block_identifier=block)

        usdc = settings.CORE_WSS.functions.tokenBalanceOf(id).call(block_identifier=block)

        sher = settings.CORE_WSS.functions.sherRewards(id).call(block_identifier=block)

        s = StakingPositions()
        s.id = id
        s.owner = owner
        s.lockup_end = datetime.fromtimestamp(lockup_end)
        s.usdc = usdc
        s.sher = sher

        session.add(s)

    @staticmethod
    def update(session, id, owner):
        session.query(StakingPositions).filter_by(id=id).one().owner = owner

    @staticmethod
    def delete(session, id):
        session.query(StakingPositions).filter_by(id=id).one().delete()

    @staticmethod
    def get(session, owner):
        return session.query(StakingPositions).filter_by(owner=owner).order_by(desc(StakingPositions.lockup_end)).all()

    def get_balance_data(self, block):
        usdc = settings.CORE_WSS.functions.tokenBalanceOf(self.id).call(block_identifier=block)

        factor = usdc / self.usdc
        return usdc, factor

    def to_dict(self):
        """Converts object to dict.
        @return: dict
        """
        d = {}
        for column in self.__table__.columns:
            data = getattr(self, column.name)
            if column.name in ["lockup_end"] and data is not None:
                d[column.name] = int(data.timestamp())
                continue
            d[column.name] = data
        return d

    def to_json(self):
        """Converts object to JSON.
        @return: JSON data
        """
        return json.dumps(self.to_dict(), default=str)
import json
from datetime import datetime

from sqlalchemy import Column, String
from sqlalchemy.dialects.postgresql import NUMERIC, TIMESTAMP

import settings
from models.base import Base


class FundraisePositions(Base):
    __tablename__ = "fundraise_positions"

    # id is actually the owner's address
    id = Column(String(42), primary_key=True)
    stake = Column(NUMERIC(78), nullable=False)
    contribution = Column(NUMERIC(78), nullable=False)
    reward = Column(NUMERIC(78), nullable=False)
    claimable_at = Column(TIMESTAMP, nullable=False)

    @staticmethod
    def insert(session, block, owner, stake, contribution, reward):
        claimable_at = settings.SHER_CLAIM_AT

        p = FundraisePositions()
        p.id = owner
        p.stake = stake
        p.contribution = contribution
        p.reward = reward
        p.claimable_at = datetime.fromtimestamp(claimable_at)

        session.add(p)

    @staticmethod
    def update(session, id, stake, contribution, reward):
        p = session.query(FundraisePositions).filter_by(id=id).one()
        p.stake = stake
        p.contribution = contribution
        p.reward = reward

    @staticmethod
    def get(session, owner):
        return session.query(FundraisePositions).filter_by(id=owner).one_or_none()

    def to_dict(self):
        """Converts object to dict.
        @return: dict
        """
        d = {}
        for column in self.__table__.columns:
            data = getattr(self, column.name)
            if column.name in ["claimable_at"] and data is not None:
                d[column.name] = int(data.timestamp())
                continue
            d[column.name] = data
        return d

    def to_json(self):
        """Converts object to JSON.
        @return: JSON data
        """
        return json.dumps(self.to_dict(), default=str)

import json
import logging
from datetime import datetime

from sqlalchemy import Column, Integer, String, desc
from sqlalchemy.dialects.postgresql import BIGINT, NUMERIC, TIMESTAMP

from models.base import Base
from utils import get_core_contract_token_values

logger = logging.getLogger(__name__)


class StakingPositions(Base):
    __tablename__ = "staking_positions"

    id = Column(BIGINT, primary_key=True)
    owner = Column(String(42), nullable=False)
    lockup_end = Column(TIMESTAMP, nullable=False)
    usdc = Column(NUMERIC(78), nullable=False)
    sher = Column(NUMERIC(78), nullable=False)
    restake_count = Column(Integer, nullable=False, default=0, server_default="0")

    @staticmethod
    def get_oldest_position(session):
        return (
            session.query(StakingPositions)
            .filter(StakingPositions.restake_count == 0)
            .order_by(StakingPositions.id)
            .first()
        )

    @staticmethod
    def insert(session, block, id, owner):
        logger.info("Saving staking position #%s for %s", id, owner)
        token_values = get_core_contract_token_values(block=block, token_id=id)

        lockup_end = token_values["lockup_end"]
        usdc = int(token_values["usdc"])
        sher = int(token_values["sher"])

        s = StakingPositions()
        s.id = id
        s.owner = owner
        s.lockup_end = datetime.fromtimestamp(lockup_end)
        s.usdc = usdc
        s.sher = sher

        session.add(s)

    @staticmethod
    def update(session, id, owner):
        logger.info("Transferring staking position #%s to %s", id, owner)
        session.query(StakingPositions).filter_by(id=id).one().owner = owner

    @staticmethod
    def delete(session, id):
        logger.info("Deleting staking position #%s", id)
        session.query(StakingPositions).filter_by(id=id).delete()

    @staticmethod
    def get(session, owner):
        return session.query(StakingPositions).filter_by(owner=owner).order_by(desc(StakingPositions.lockup_end)).all()

    @staticmethod
    def restake(session, block, id):
        logger.info("Restaking position #%s", id)
        position = session.query(StakingPositions).filter_by(id=id).first()

        if not position:
            logger.error("Staking position %s not found!", id)
            return

        # Update staking position with latest blockchain data
        token_values = get_core_contract_token_values(block=block, token_id=id)
        lockup_end = token_values["lockup_end"]
        usdc = int(token_values["usdc"])
        sher = int(token_values["sher"])

        position.lockup_end = datetime.fromtimestamp(lockup_end)
        position.usdc = usdc
        position.sher = sher

        position.restake_count += 1

    def get_balance_data(self, block):
        token_values = get_core_contract_token_values(block=block, token_id=self.id)
        usdc = int(token_values["usdc"])

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

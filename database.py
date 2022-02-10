import settings
from datetime import datetime, timedelta

from sqlalchemy import Column, Integer, String, Float, desc
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.dialects.postgresql import TIMESTAMP, NUMERIC, BIGINT, DOUBLE_PRECISION

Base = declarative_base()
engine = settings.DB
Session = sessionmaker(bind=engine)

class StakingPositions(Base):
    __tablename__ = 'staking_positions'

    id = Column(BIGINT, primary_key=True)
    owner = Column(String(42), nullable=False)
    lockup_end = Column(TIMESTAMP, nullable=False)
    usdc = Column(NUMERIC(78), nullable=False)
    sher = Column(NUMERIC(78), nullable=False)

    @staticmethod
    def get_for_factor(session):
        # Get biggest USDC position that is not about to expire
        safe_time = datetime.utcnow() + timedelta(days=7)

        return session.query(StakingPositions).\
            filter(StakingPositions.lockup_end > safe_time).\
            order_by(desc(StakingPositions.usdc)).\
            first()

    @staticmethod
    def insert(session, block, id, owner):
        lockup_end = settings.CORE_WSS.functions\
            .lockupEnd(id)\
            .call(block_identifier=block)

        usdc = settings.CORE_WSS.functions\
            .tokenBalanceOf(id)\
            .call(block_identifier=block)

        sher = settings.CORE_WSS.functions\
            .sherRewards(id)\
            .call(block_identifier=block)

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
        return session.query(StakingPositions).filter_by(owner=owner).all()

    def get_balance_data(self, block):
        usdc = settings.CORE_WSS.functions\
            .tokenBalanceOf(self.id)\
            .call(block_identifier=block)

        factor = usdc / self.usdc
        return usdc, factor

# Single row
class StakingPositionsMeta(Base):
    __tablename__ = 'staking_positions_meta'

    id = Column(Integer, primary_key=True, default=1)
    usdc_last_updated = Column(TIMESTAMP, nullable=False, default=datetime.min)
    usdc_last_updated_block = Column(Integer, nullable=False, default=0)
    # apy_human = Column(Float, nullable=False, default=0)
    # apy_50ms_factor = Column(NUMERIC(79, 78), nullable=False, default=0)

    @staticmethod
    def get(session):
        return session.query(StakingPositionsMeta).one()

    @staticmethod
    def update(session, block, balance_factor):
        timestamp = settings.WEB3_WSS.eth.get_block(block)["timestamp"]

        session.execute(
            "update staking_positions set usdc = usdc * :factor;",
            {'factor': balance_factor}
        )

        data = StakingPositionsMeta.get(session)
        data.usdc_last_updated = datetime.fromtimestamp(timestamp)
        data.usdc_last_updated_block = block

# Single row
class IndexerState(Base):
    __tablename__ = 'indexer_state'

    id = Column(Integer, primary_key=True, default=1)
    last_block = Column(Integer, nullable=False, default=0)

def main():
    Base.metadata.create_all(engine)

    s = Session()
    s.add(StakingPositionsMeta())
    s.add(IndexerState())
    s.commit()
    s.close()

if __name__ == "__main__":
    main()
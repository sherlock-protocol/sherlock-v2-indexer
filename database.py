import settings
from datetime import datetime, timedelta

from sqlalchemy import Column, Integer, String, Float, desc
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.dialects.postgresql import TIMESTAMP, NUMERIC, BIGINT, DOUBLE_PRECISION

Base = declarative_base()
engine = settings.DB
Session = sessionmaker(bind=engine)

class FundraisePositions(Base):
    __tablename__ = 'fundraise_positions'

    # id is actually the owner's address
    id = Column(String(42), primary_key=True)
    stake = Column(NUMERIC(78), nullable=False)
    contribution = Column(NUMERIC(78), nullable=False)
    reward = Column(NUMERIC(78), nullable=False)
    claimable_at = Column(TIMESTAMP, nullable=False)

    @staticmethod
    def insert(session, block, owner, stake, contribution, reward):
        claimable_at = settings.SHER_CLAIM_WSS.functions\
            .claimableAt()\
            .call(block_identifier=block)

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

# Single row
class StakingPositionsMeta(Base):
    __tablename__ = 'staking_positions_meta'

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
            {'factor': balance_factor}
        )

        data = StakingPositionsMeta.get(session)
        data.usdc_last_updated = datetime.fromtimestamp(timestamp)
        data.usdc_last_updated_block = block

# Single row
class IndexerState(Base):
    __tablename__ = 'indexer_state'

    id = Column(Integer, primary_key=True, default=1)
    last_block = Column(Integer, nullable=False, default=14249220)

def main():
    Base.metadata.create_all(engine)

    s = Session()
    s.add(StakingPositionsMeta())
    s.add(IndexerState())
    s.commit()
    s.close()

if __name__ == "__main__":
    main()

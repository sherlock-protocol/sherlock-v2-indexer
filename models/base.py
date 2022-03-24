from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

import settings

Base = declarative_base()
engine = settings.DB
Session = sessionmaker(bind=engine)

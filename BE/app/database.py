from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Define local database credentials
LOCAL_DATABASE_HOST = "localhost"
LOCAL_DATABASE_PORT = "5432"
LOCAL_DATABASE_USERNAME = "postgres"
LOCAL_DATABASE_PASSWORD = "postgres"
LOCAL_DATABASE_NAME = "TripTangle"

# Construct the database URL properly
LOCAL_DATABASE_URL = (
    f"postgresql+psycopg://{LOCAL_DATABASE_USERNAME}:{LOCAL_DATABASE_PASSWORD}"
    f"@{LOCAL_DATABASE_HOST}:{LOCAL_DATABASE_PORT}/{LOCAL_DATABASE_NAME}"
)

# Get database URL from environment or use local default
DATABASE_URL = os.getenv("NEW_DATABASE_URL", LOCAL_DATABASE_URL)

# ✅ FIX: Remove unnecessary `.replace()` call
engine = create_engine(DATABASE_URL)

# ✅ Initialize SessionLocal and Base
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ✅ Dependency for database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

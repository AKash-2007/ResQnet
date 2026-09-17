import os
from typing import List, Union
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "ResQnet"
    ENVIRONMENT: str = "development"
    
    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql+asyncpg://resqnet:resqnet_secret@localhost:5432/resqnet_db"
    )
    SYNC_DATABASE_URL: str = os.getenv(
        "SYNC_DATABASE_URL",
        "postgresql://resqnet:resqnet_secret@localhost:5432/resqnet_db"
    )
    
    # JWT & Cryptography
    JWT_SECRET: str = os.getenv("JWT_SECRET", "resqnet_super_secure_jwt_secret_key_32_bytes_min")
    JWT_REFRESH_SECRET: str = os.getenv("JWT_REFRESH_SECRET", "resqnet_super_secure_refresh_secret_key_32_bytes_min")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    
    # Community Emergency Search Radius
    DEFAULT_RADIUS_METERS: int = 1000
    COMPACT_RADIUS_METERS: int = 500
    
    # Privacy Threshold: Minimum users count required before returning specific breakdown
    PRIVACY_MIN_COUNT_THRESHOLD: int = 3
    
    # Firebase
    FCM_SERVER_KEY: str = os.getenv("FCM_SERVER_KEY", "")
    
    # CORS
    ALLOWED_ORIGINS: List[str] = ["*"]

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

settings = Settings()

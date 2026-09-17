import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, Float
from sqlalchemy.orm import relationship
from app.database.session import Base

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String, nullable=False)
    gender = Column(String, default="Not specified", nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    profile = relationship("Profile", back_populates="user", uselist=False, cascade="all, delete-orphan", lazy="joined")
    incidents = relationship("EmergencyIncident", back_populates="requester")
    responded_emergencies = relationship("EmergencyResponder", back_populates="helper")
    devices = relationship("NotificationDevice", back_populates="user", cascade="all, delete-orphan")


class Profile(Base):
    __tablename__ = "profiles"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    available_to_help = Column(Boolean, default=False, nullable=False, index=True)
    language = Column(String, default="en", nullable=False)
    theme_mode = Column(String, default="system", nullable=False)
    
    # Last known location for helper matching (TTL/privacy managed)
    last_known_latitude = Column(Float, nullable=True)
    last_known_longitude = Column(Float, nullable=True)
    last_location_updated_at = Column(DateTime(timezone=True), nullable=True)

    user = relationship("User", back_populates="profile", lazy="joined")

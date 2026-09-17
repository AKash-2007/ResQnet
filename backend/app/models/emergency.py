import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database.session import Base

class EmergencyIncident(Base):
    __tablename__ = "emergency_incidents"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    requester_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    emergency_type = Column(String, nullable=False, index=True) # MEDICAL, FIRE, ACCIDENT, SOS
    priority = Column(String, default="HIGH", nullable=False)   # NORMAL, HIGH, CRITICAL
    status = Column(String, default="ACTIVE", nullable=False, index=True) # ACTIVE, RESPONDING, RESOLVED, CANCELLED
    
    # Location coordinates
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    address_hint = Column(String, nullable=True)
    
    helpers_notified_count = Column(Integer, default=0, nullable=False)
    helpers_responding_count = Column(Integer, default=0, nullable=False)

    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    requester = relationship("User", back_populates="incidents")
    responders = relationship("EmergencyResponder", back_populates="incident", cascade="all, delete-orphan")

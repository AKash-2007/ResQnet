import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database.session import Base

class EmergencyResponder(Base):
    __tablename__ = "emergency_responders"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    incident_id = Column(String, ForeignKey("emergency_incidents.id", ondelete="CASCADE"), nullable=False, index=True)
    helper_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    status = Column(String, default="EN_ROUTE", nullable=False) # EN_ROUTE, ARRIVED, CANCELLED
    responded_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    # Relationships
    incident = relationship("EmergencyIncident", back_populates="responders")
    helper = relationship("User", back_populates="responded_emergencies")

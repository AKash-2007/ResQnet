from typing import Optional
from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict

class EmergencyCreateRequest(BaseModel):
    emergency_type: str = Field(..., description="MEDICAL, FIRE, ACCIDENT, or SOS")
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    address_hint: Optional[str] = None
    radius_meters: Optional[int] = Field(1000, ge=100, le=5000)

class EmergencyLocationUpdateRequest(BaseModel):
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)

class EmergencyResponderResponse(BaseModel):
    id: str
    incident_id: str
    helper_id: str
    status: str
    responded_at: datetime

    model_config = ConfigDict(from_attributes=True)

class EmergencyResponse(BaseModel):
    id: str
    requester_id: str
    emergency_type: str
    priority: str
    status: str
    latitude: float
    longitude: float
    address_hint: Optional[str] = None
    helpers_notified_count: int
    helpers_responding_count: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    resolved_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

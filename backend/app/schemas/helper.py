from pydantic import BaseModel, Field

class HelperLocationUpdate(BaseModel):
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)

class HelperAvailabilityUpdate(BaseModel):
    available_to_help: bool

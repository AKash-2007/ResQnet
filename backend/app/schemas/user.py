from typing import Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr, ConfigDict

class ProfileResponse(BaseModel):
    available_to_help: bool
    language: str
    theme_mode: str
    last_known_latitude: Optional[float] = None
    last_known_longitude: Optional[float] = None

    model_config = ConfigDict(from_attributes=True)

class UserResponse(BaseModel):
    id: str
    email: EmailStr
    full_name: str
    gender: str
    is_active: bool
    available_to_help: bool = False
    language: str = "en"
    theme_mode: str = "system"
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class UserUpdateRequest(BaseModel):
    full_name: Optional[str] = None
    gender: Optional[str] = None
    language: Optional[str] = None
    theme_mode: Optional[str] = None

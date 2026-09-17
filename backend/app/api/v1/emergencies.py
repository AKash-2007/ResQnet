from typing import List
from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.session import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.services.emergency_service import EmergencyService
from app.repositories.emergency_repository import EmergencyRepository
from app.schemas.emergency import (
    EmergencyCreateRequest,
    EmergencyResponse,
    EmergencyLocationUpdateRequest,
    EmergencyResponderResponse,
)

router = APIRouter(prefix="/emergencies", tags=["Emergencies"])

@router.post("", response_model=EmergencyResponse, status_code=status.HTTP_201_CREATED)
async def create_emergency(
    req: EmergencyCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = EmergencyService(db)
    incident = await service.create_emergency(requester_id=current_user.id, req=req)
    return incident

@router.get("/history", response_model=List[EmergencyResponse])
async def get_emergency_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = EmergencyRepository(db)
    return await repo.get_history_by_user(user_id=current_user.id)

@router.get("/{id}", response_model=EmergencyResponse)
async def get_emergency(
    id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = EmergencyRepository(db)
    incident = await repo.get_by_id(id)
    if not incident:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Emergency incident not found.")
    return incident

@router.post("/{id}/respond", response_model=EmergencyResponderResponse)
async def respond_to_emergency(
    id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = EmergencyService(db)
    return await service.respond_as_helper(incident_id=id, helper_id=current_user.id)

@router.post("/{id}/decline")
async def decline_emergency(
    id: str,
    current_user: User = Depends(get_current_user),
):
    return {"message": "Emergency alert declined."}

@router.post("/{id}/location", response_model=EmergencyResponse)
async def update_emergency_location(
    id: str,
    req: EmergencyLocationUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = EmergencyService(db)
    return await service.update_location(incident_id=id, user_id=current_user.id, lat=req.latitude, lng=req.longitude)

@router.post("/{id}/resolve", response_model=EmergencyResponse)
async def resolve_emergency(
    id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = EmergencyService(db)
    return await service.resolve_emergency(incident_id=id, user_id=current_user.id)

@router.post("/{id}/cancel", response_model=EmergencyResponse)
async def cancel_emergency(
    id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = EmergencyService(db)
    return await service.cancel_emergency(incident_id=id, user_id=current_user.id)

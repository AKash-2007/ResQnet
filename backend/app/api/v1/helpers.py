from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.session import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.helper import HelperLocationUpdate, HelperAvailabilityUpdate
from app.services.websocket_manager import ws_manager

router = APIRouter(prefix="/helpers", tags=["Helpers"])

@router.post("/location")
async def update_helper_location(
    req: HelperLocationUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = UserRepository(db)
    await repo.update_helper_location(user_id=current_user.id, lat=req.latitude, lng=req.longitude)
    return {"message": "Location updated successfully."}

@router.patch("/availability")
async def update_helper_availability(
    req: HelperAvailabilityUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    repo = UserRepository(db)
    await repo.update_availability(user_id=current_user.id, available=req.available_to_help)
    if not req.available_to_help:
        ws_manager.disconnect_user(current_user.id)
    return {"message": "Availability updated successfully.", "available_to_help": req.available_to_help}

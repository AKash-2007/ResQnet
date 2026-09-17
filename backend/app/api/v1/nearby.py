from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.session import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.services.nearby_service import NearbySafetyService
from app.schemas.nearby import NearbyStatsResponse

router = APIRouter(prefix="/nearby", tags=["Nearby Safety"])

@router.get("/stats", response_model=NearbyStatsResponse)
async def get_nearby_safety_stats(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    radius_meters: int = Query(1000, ge=100, le=5000),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = NearbySafetyService(db)
    return await service.get_privacy_safe_stats(
        latitude=latitude,
        longitude=longitude,
        radius_meters=radius_meters,
    )

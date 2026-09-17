from sqlalchemy.ext.asyncio import AsyncSession
from app.repositories.helper_repository import HelperRepository
from app.schemas.nearby import NearbyStatsResponse
from app.core.config import settings

class NearbySafetyService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.helper_repo = HelperRepository(session)

    async def get_privacy_safe_stats(
        self,
        latitude: float,
        longitude: float,
        radius_meters: int = 1000,
    ) -> NearbyStatsResponse:
        total, male, female, other = await self.helper_repo.get_nearby_safety_aggregate(
            latitude=latitude,
            longitude=longitude,
            radius_meters=radius_meters,
        )

        # Apply k-anonymity / privacy threshold
        # If total user count is below threshold (e.g. < 3), mask specific breakdown
        # to prevent identifying a single individual nearby.
        if 0 < total < settings.PRIVACY_MIN_COUNT_THRESHOLD:
            return NearbyStatsResponse(
                total_users=total,
                male_count=0,
                female_count=0,
                other_count=0,
                radius_meters=radius_meters,
                is_masked_for_privacy=True,
                notice="Specific demographic breakdown masked to protect member privacy in low-density area.",
            )

        return NearbyStatsResponse(
            total_users=total,
            male_count=male,
            female_count=female,
            other_count=other,
            radius_meters=radius_meters,
            is_masked_for_privacy=False,
        )

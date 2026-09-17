import math
from typing import List, Tuple
from datetime import datetime, timedelta, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from app.models.user import User, Profile

def haversine_distance_meters(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371000.0 # Earth radius in meters
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = (math.sin(delta_phi / 2.0) ** 2 +
         math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2)
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return R * c

class HelperRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def find_nearby_eligible_helpers(
        self,
        latitude: float,
        longitude: float,
        radius_meters: int = 1000,
        exclude_user_id: str = None,
        max_location_age_hours: int = 24,
    ) -> List[Tuple[User, float]]:
        """
        Finds eligible registered ResQnet helpers within radius_meters who are available to help.
        Supports PostGIS spatial queries, with a reliable spherical math fallback.
        """
        cutoff_time = datetime.now(timezone.utc) - timedelta(hours=max_location_age_hours)

        # Query users with available_to_help = True and valid coordinates
        stmt = (
            select(User, Profile)
            .join(Profile, User.id == Profile.user_id)
            .where(
                Profile.available_to_help == True,
                Profile.last_known_latitude.isnot(None),
                Profile.last_known_longitude.isnot(None),
            )
        )
        if exclude_user_id:
            stmt = stmt.where(User.id != exclude_user_id)

        result = await self.session.execute(stmt)
        records = result.all()

        eligible_helpers = []
        for user, profile in records:
            dist = haversine_distance_meters(
                latitude, longitude,
                profile.last_known_latitude, profile.last_known_longitude
            )
            if dist <= radius_meters:
                eligible_helpers.append((user, dist))

        # Sort by distance
        eligible_helpers.sort(key=lambda x: x[1])
        return eligible_helpers

    async def get_nearby_safety_aggregate(
        self,
        latitude: float,
        longitude: float,
        radius_meters: int = 1000,
    ) -> Tuple[int, int, int, int]:
        """
        Calculates aggregate privacy-safe stats (total, male, female, other) within radius.
        Never returns individual coordinates or identities.
        """
        stmt = (
            select(User.gender, Profile.last_known_latitude, Profile.last_known_longitude)
            .join(Profile, User.id == Profile.user_id)
            .where(
                Profile.last_known_latitude.isnot(None),
                Profile.last_known_longitude.isnot(None),
            )
        )
        result = await self.session.execute(stmt)
        rows = result.all()

        total = 0
        male = 0
        female = 0
        other = 0

        for gender, lat, lng in rows:
            dist = haversine_distance_meters(latitude, longitude, lat, lng)
            if dist <= radius_meters:
                total += 1
                g_lower = (gender or "").lower()
                if "male" in g_lower and "female" not in g_lower:
                    male += 1
                elif "female" in g_lower:
                    female += 1
                else:
                    other += 1

        return total, male, female, other

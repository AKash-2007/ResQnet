from pydantic import BaseModel

class NearbyStatsResponse(BaseModel):
    total_users: int
    male_count: int
    female_count: int
    other_count: int = 0
    radius_meters: int
    is_masked_for_privacy: bool = False
    notice: str = "Exact locations and individual identities are never shared publicly or displayed on maps."

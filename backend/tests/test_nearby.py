import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_nearby_safety_aggregate_privacy(client: AsyncClient):
    # 1. Register a user and login
    await client.post("/api/v1/auth/register", json={
        "full_name": "Privacy Tester",
        "email": "privacy@resqnet.org",
        "gender": "Female",
        "password": "Password123!",
    })
    login_res = await client.post("/api/v1/auth/login", json={"email": "privacy@resqnet.org", "password": "Password123!"})
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Query nearby safety stats
    res = await client.get(
        "/api/v1/nearby/stats?latitude=12.9716&longitude=77.5946&radius_meters=1000",
        headers=headers,
    )
    assert res.status_code == 200
    data = res.json()

    # Verify strictly aggregate statistics
    assert "total_users" in data
    assert "male_count" in data
    assert "female_count" in data
    assert "radius_meters" in data

    # Critical Privacy Verification:
    # Ensure no individual identities, phone numbers, or exact coordinates are leaked
    assert "users" not in data
    assert "names" not in data
    assert "coordinates" not in data
    assert "locations" not in data
    assert "phone_numbers" not in data

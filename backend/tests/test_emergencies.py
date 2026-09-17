import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_emergency_incident_lifecycle(client: AsyncClient):
    # 1. Register requester and helper
    req_res = await client.post("/api/v1/auth/register", json={
        "full_name": "Requester User",
        "email": "requester@resqnet.org",
        "gender": "Male",
        "password": "Password123!",
    })
    helper_res = await client.post("/api/v1/auth/register", json={
        "full_name": "Nearby Helper",
        "email": "helper1@resqnet.org",
        "gender": "Female",
        "password": "Password123!",
    })

    # Login both
    login_req = await client.post("/api/v1/auth/login", json={"email": "requester@resqnet.org", "password": "Password123!"})
    login_help = await client.post("/api/v1/auth/login", json={"email": "helper1@resqnet.org", "password": "Password123!"})

    token_req = login_req.json()["access_token"]
    token_help = login_help.json()["access_token"]

    headers_req = {"Authorization": f"Bearer {token_req}"}
    headers_help = {"Authorization": f"Bearer {token_help}"}

    # Set helper availability and coordinates (500m away)
    await client.patch("/api/v1/helpers/availability", json={"available_to_help": True}, headers=headers_help)
    await client.post("/api/v1/helpers/location", json={"latitude": 12.9730, "longitude": 77.5950}, headers=headers_help)

    # 2. Requester creates Medical Emergency
    em_res = await client.post("/api/v1/emergencies", json={
        "emergency_type": "MEDICAL",
        "latitude": 12.9716,
        "longitude": 77.5946,
        "radius_meters": 1000,
    }, headers=headers_req)

    assert em_res.status_code == 201
    incident = em_res.json()
    incident_id = incident["id"]
    assert incident["emergency_type"] == "MEDICAL"
    assert incident["status"] == "ACTIVE"
    assert incident["helpers_notified_count"] >= 1

    # 3. Helper responds ("I'M COMING")
    respond_res = await client.post(f"/api/v1/emergencies/{incident_id}/respond", headers=headers_help)
    assert respond_res.status_code == 200
    responder_data = respond_res.json()
    assert responder_data["status"] == "EN_ROUTE"

    # Verify incident status updated to RESPONDING and count incremented
    inc_check = await client.get(f"/api/v1/emergencies/{incident_id}", headers=headers_req)
    assert inc_check.json()["status"] == "RESPONDING"
    assert inc_check.json()["helpers_responding_count"] == 1

    # 4. Requester updates location
    loc_res = await client.post(f"/api/v1/emergencies/{incident_id}/location", json={
        "latitude": 12.9718,
        "longitude": 77.5948,
    }, headers=headers_req)
    assert loc_res.status_code == 200
    assert loc_res.json()["latitude"] == 12.9718

    # 5. Unauthorized cancellation attempt by helper should fail
    fail_cancel = await client.post(f"/api/v1/emergencies/{incident_id}/cancel", headers=headers_help)
    assert fail_cancel.status_code == 403

    # 6. Requester marks as safe (resolves)
    resolve_res = await client.post(f"/api/v1/emergencies/{incident_id}/resolve", headers=headers_req)
    assert resolve_res.status_code == 200
    assert resolve_res.json()["status"] == "RESOLVED"

@pytest.mark.asyncio
async def test_unavailable_helper_and_requester_not_notified(client: AsyncClient):
    # Register requester and a helper who turns OFF available_to_help
    req_res = await client.post("/api/v1/auth/register", json={
        "full_name": "Solo Requester",
        "email": "solo@resqnet.org",
        "gender": "Male",
        "password": "Password123!",
    })
    help_res = await client.post("/api/v1/auth/register", json={
        "full_name": "Off-Duty Helper",
        "email": "offduty@resqnet.org",
        "gender": "Female",
        "password": "Password123!",
    })
    token_req = (await client.post("/api/v1/auth/login", json={"email": "solo@resqnet.org", "password": "Password123!"})).json()["access_token"]
    token_help = (await client.post("/api/v1/auth/login", json={"email": "offduty@resqnet.org", "password": "Password123!"})).json()["access_token"]

    headers_req = {"Authorization": f"Bearer {token_req}"}
    headers_help = {"Authorization": f"Bearer {token_help}"}

    # Off-duty helper sets location but explicitly sets available_to_help = FALSE
    await client.post("/api/v1/helpers/location", json={"latitude": 12.9716, "longitude": 77.5946}, headers=headers_help)
    await client.patch("/api/v1/helpers/availability", json={"available_to_help": False}, headers=headers_help)

    # Requester also sets location (same location) and is available_to_help = True
    await client.post("/api/v1/helpers/location", json={"latitude": 12.9716, "longitude": 77.5946}, headers=headers_req)
    await client.patch("/api/v1/helpers/availability", json={"available_to_help": True}, headers=headers_req)

    # Requester triggers emergency
    em_res = await client.post("/api/v1/emergencies", json={
        "emergency_type": "SOS",
        "latitude": 12.9716,
        "longitude": 77.5946,
        "radius_meters": 1000,
    }, headers=headers_req)

    assert em_res.status_code == 201
    incident = em_res.json()
    # helpers_notified_count MUST be 0 because:
    # 1. Requester cannot be notified for their own emergency
    # 2. Off-duty helper has available_to_help = False
    assert incident["helpers_notified_count"] == 0

import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_register_and_login_flow(client: AsyncClient):
    # 1. Register
    reg_payload = {
        "full_name": "Test Helper",
        "email": "helper@resqnet.org",
        "gender": "Female",
        "password": "SecurePassword123!",
    }
    reg_res = await client.post("/api/v1/auth/register", json=reg_payload)
    assert reg_res.status_code == 201
    user_data = reg_res.json()
    assert user_data["email"] == "helper@resqnet.org"
    assert user_data["full_name"] == "Test Helper"
    assert "password" not in user_data
    assert "hashed_password" not in user_data

    # 2. Duplicate registration should fail
    dup_res = await client.post("/api/v1/auth/register", json=reg_payload)
    assert dup_res.status_code == 400

    # 3. Login with correct password
    login_payload = {
        "email": "helper@resqnet.org",
        "password": "SecurePassword123!",
    }
    login_res = await client.post("/api/v1/auth/login", json=login_payload)
    assert login_res.status_code == 200
    token_data = login_res.json()
    assert "access_token" in token_data
    assert "refresh_token" in token_data

    access_token = token_data["access_token"]
    refresh_token = token_data["refresh_token"]

    # 4. Access protected endpoint /users/me
    headers = {"Authorization": f"Bearer {access_token}"}
    me_res = await client.get("/api/v1/users/me", headers=headers)
    assert me_res.status_code == 200
    assert me_res.json()["email"] == "helper@resqnet.org"

    # 5. Refresh token rotation
    refresh_res = await client.post("/api/v1/auth/refresh", json={"refresh_token": refresh_token})
    assert refresh_res.status_code == 200
    assert "access_token" in refresh_res.json()

@pytest.mark.asyncio
async def test_login_invalid_credentials(client: AsyncClient):
    res = await client.post("/api/v1/auth/login", json={
        "email": "nonexistent@resqnet.org",
        "password": "WrongPassword!",
    })
    assert res.status_code == 401

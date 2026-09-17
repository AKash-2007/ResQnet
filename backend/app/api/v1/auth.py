from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.session import get_db
from app.services.auth_service import AuthService
from app.schemas.auth import (
    RegisterRequest,
    LoginRequest,
    TokenResponse,
    RefreshTokenRequest,
    ForgotPasswordRequest,
)
from app.schemas.user import UserResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    auth_service = AuthService(db)
    user = await auth_service.register(req)
    return UserResponse(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        gender=user.gender,
        is_active=user.is_active,
        available_to_help=user.profile.available_to_help if user.profile else False,
        language=user.profile.language if user.profile else "en",
        theme_mode=user.profile.theme_mode if user.profile else "system",
        created_at=user.created_at,
    )

@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    auth_service = AuthService(db)
    return await auth_service.login(req)

@router.post("/refresh", response_model=TokenResponse)
async def refresh(req: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    auth_service = AuthService(db)
    return await auth_service.refresh(req.refresh_token)

@router.post("/logout")
async def logout():
    return {"message": "Successfully logged out."}

@router.post("/forgot-password")
async def forgot_password(req: ForgotPasswordRequest):
    return {"message": f"Password reset instructions sent if account exists for {req.email}."}

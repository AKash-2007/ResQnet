from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.session import get_db
from app.api.deps import get_current_user
from app.models.user import User, Profile
from app.schemas.user import UserResponse, UserUpdateRequest

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/me", response_model=UserResponse)
async def get_my_profile(current_user: User = Depends(get_current_user)):
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name,
        gender=current_user.gender,
        is_active=current_user.is_active,
        available_to_help=current_user.profile.available_to_help if current_user.profile else False,
        language=current_user.profile.language if current_user.profile else "en",
        theme_mode=current_user.profile.theme_mode if current_user.profile else "system",
        created_at=current_user.created_at,
    )

@router.patch("/me", response_model=UserResponse)
async def update_my_profile(
    req: UserUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if req.full_name is not None:
        current_user.full_name = req.full_name
    if req.gender is not None:
        current_user.gender = req.gender
    if current_user.profile:
        if req.language is not None:
            current_user.profile.language = req.language
        if req.theme_mode is not None:
            current_user.profile.theme_mode = req.theme_mode

    await db.commit()
    await db.refresh(current_user)

    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name,
        gender=current_user.gender,
        is_active=current_user.is_active,
        available_to_help=current_user.profile.available_to_help if current_user.profile else False,
        language=current_user.profile.language if current_user.profile else "en",
        theme_mode=current_user.profile.theme_mode if current_user.profile else "system",
        created_at=current_user.created_at,
    )

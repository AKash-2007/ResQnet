from typing import Optional
from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from sqlalchemy.orm import selectinload
from app.models.user import User, Profile

class UserRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, user_id: str) -> Optional[User]:
        stmt = select(User).options(selectinload(User.profile)).where(User.id == user_id)
        result = await self.session.execute(stmt)
        return result.scalars().first()

    async def get_by_email(self, email: str) -> Optional[User]:
        stmt = select(User).options(selectinload(User.profile)).where(User.email == email.lower())
        result = await self.session.execute(stmt)
        return result.scalars().first()

    async def create_user(self, email: str, full_name: str, gender: str, hashed_password: str) -> User:
        user = User(
            email=email.lower(),
            full_name=full_name,
            gender=gender,
            hashed_password=hashed_password,
        )
        self.session.add(user)
        await self.session.flush()

        profile = Profile(user_id=user.id)
        self.session.add(profile)
        user.profile = profile
        await self.session.commit()
        return user

    async def update_helper_location(self, user_id: str, lat: float, lng: float) -> None:
        stmt = (
            update(Profile)
            .where(Profile.user_id == user_id)
            .values(
                last_known_latitude=lat,
                last_known_longitude=lng,
                last_location_updated_at=datetime.now(timezone.utc),
            )
        )
        await self.session.execute(stmt)
        await self.session.commit()

    async def update_availability(self, user_id: str, available: bool) -> None:
        stmt = (
            update(Profile)
            .where(Profile.user_id == user_id)
            .values(available_to_help=available)
        )
        await self.session.execute(stmt)
        await self.session.commit()

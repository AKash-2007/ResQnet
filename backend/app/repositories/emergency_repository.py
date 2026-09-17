from typing import Optional, List
from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, desc
from app.models.emergency import EmergencyIncident
from app.models.responder import EmergencyResponder

class EmergencyRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create_incident(
        self,
        requester_id: str,
        emergency_type: str,
        latitude: float,
        longitude: float,
        priority: str = "HIGH",
        address_hint: Optional[str] = None,
        helpers_notified_count: int = 0,
    ) -> EmergencyIncident:
        incident = EmergencyIncident(
            requester_id=requester_id,
            emergency_type=emergency_type.upper(),
            priority=priority,
            status="ACTIVE",
            latitude=latitude,
            longitude=longitude,
            address_hint=address_hint,
            helpers_notified_count=helpers_notified_count,
            helpers_responding_count=0,
        )
        self.session.add(incident)
        await self.session.commit()
        await self.session.refresh(incident)
        return incident

    async def get_by_id(self, incident_id: str) -> Optional[EmergencyIncident]:
        stmt = select(EmergencyIncident).where(EmergencyIncident.id == incident_id)
        result = await self.session.execute(stmt)
        return result.scalars().first()

    async def update_location(self, incident_id: str, latitude: float, longitude: float) -> Optional[EmergencyIncident]:
        stmt = (
            update(EmergencyIncident)
            .where(EmergencyIncident.id == incident_id)
            .values(latitude=latitude, longitude=longitude, updated_at=datetime.now(timezone.utc))
            .returning(EmergencyIncident)
        )
        result = await self.session.execute(stmt)
        await self.session.commit()
        return result.scalars().first()

    async def resolve_incident(self, incident_id: str) -> Optional[EmergencyIncident]:
        stmt = (
            update(EmergencyIncident)
            .where(EmergencyIncident.id == incident_id)
            .values(status="RESOLVED", resolved_at=datetime.now(timezone.utc), updated_at=datetime.now(timezone.utc))
            .returning(EmergencyIncident)
        )
        result = await self.session.execute(stmt)
        await self.session.commit()
        return result.scalars().first()

    async def cancel_incident(self, incident_id: str) -> Optional[EmergencyIncident]:
        stmt = (
            update(EmergencyIncident)
            .where(EmergencyIncident.id == incident_id)
            .values(status="CANCELLED", resolved_at=datetime.now(timezone.utc), updated_at=datetime.now(timezone.utc))
            .returning(EmergencyIncident)
        )
        result = await self.session.execute(stmt)
        await self.session.commit()
        return result.scalars().first()

    async def add_responder(self, incident_id: str, helper_id: str) -> EmergencyResponder:
        responder = EmergencyResponder(
            incident_id=incident_id,
            helper_id=helper_id,
            status="EN_ROUTE",
        )
        self.session.add(responder)

        # Increment responding count
        stmt = (
            update(EmergencyIncident)
            .where(EmergencyIncident.id == incident_id)
            .values(
                helpers_responding_count=EmergencyIncident.helpers_responding_count + 1,
                status="RESPONDING",
                updated_at=datetime.now(timezone.utc),
            )
        )
        await self.session.execute(stmt)
        await self.session.commit()
        await self.session.refresh(responder)
        return responder

    async def get_history_by_user(self, user_id: str, limit: int = 50) -> List[EmergencyIncident]:
        stmt = (
            select(EmergencyIncident)
            .where(EmergencyIncident.requester_id == user_id)
            .order_by(desc(EmergencyIncident.created_at))
            .limit(limit)
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

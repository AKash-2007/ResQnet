from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.repositories.emergency_repository import EmergencyRepository
from app.repositories.helper_repository import HelperRepository
from app.services.notification_service import NotificationService
from app.services.websocket_manager import ws_manager
from app.schemas.emergency import EmergencyCreateRequest
from app.models.emergency import EmergencyIncident
from app.models.responder import EmergencyResponder
from app.models.device import NotificationDevice

class EmergencyService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.emergency_repo = EmergencyRepository(session)
        self.helper_repo = HelperRepository(session)

    async def create_emergency(self, requester_id: str, req: EmergencyCreateRequest) -> EmergencyIncident:
        # Find eligible helpers within specified radius (default 1000m or 500m)
        nearby_helpers = await self.helper_repo.find_nearby_eligible_helpers(
            latitude=req.latitude,
            longitude=req.longitude,
            radius_meters=req.radius_meters or 1000,
            exclude_user_id=requester_id,
        )

        helpers_notified_count = len(nearby_helpers)

        priority = "CRITICAL" if req.emergency_type.upper() == "SOS" else "HIGH"

        # Create emergency incident record
        incident = await self.emergency_repo.create_incident(
            requester_id=requester_id,
            emergency_type=req.emergency_type,
            latitude=req.latitude,
            longitude=req.longitude,
            priority=priority,
            address_hint=req.address_hint,
            helpers_notified_count=helpers_notified_count,
        )

        # Dispatch push notifications and live broadcast to eligible nearby helpers
        # STRICT RULE: Exclude requester and only target users who have available_to_help = True
        helper_user_ids = [h[0].id for h in nearby_helpers if h[0].id != requester_id]
        avg_distance = int(sum(h[1] for h in nearby_helpers) / len(nearby_helpers)) if nearby_helpers else 500

        # 1. Dispatch push notifications ONLY to eligible available helpers (never the requester)
        if helper_user_ids:
            device_stmt = select(NotificationDevice.fcm_token).where(
                NotificationDevice.user_id.in_(helper_user_ids),
                NotificationDevice.user_id != requester_id,
            )
            device_res = await self.session.execute(device_stmt)
            tokens = [row[0] for row in device_res.all()]
            if not tokens:
                tokens = [f"device-token-{uid}" for uid in helper_user_ids]

            await NotificationService.send_emergency_alert(
                tokens=tokens,
                emergency_type=req.emergency_type,
                approx_distance_meters=avg_distance,
                incident_id=incident.id,
            )

        # 2. Broadcast live alert via WebSockets strictly to connected eligible helpers
        alert_payload = {
            "event": "new_emergency_alert",
            "incident": {
                "id": incident.id,
                "requester_id": incident.requester_id,
                "emergency_type": incident.emergency_type,
                "latitude": incident.latitude,
                "longitude": incident.longitude,
                "status": incident.status,
                "priority": incident.priority,
                "address_hint": incident.address_hint,
                "created_at": incident.created_at.isoformat() if incident.created_at else None,
            },
            "distance_meters": avg_distance,
            "minutes_ago": 0,
        }
        await ws_manager.broadcast_emergency_to_helpers(
            helper_user_ids=helper_user_ids,
            data=alert_payload,
            exclude_user_id=requester_id,
        )

        return incident

    async def respond_as_helper(self, incident_id: str, helper_id: str) -> EmergencyResponder:
        incident = await self.emergency_repo.get_by_id(incident_id)
        if not incident:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Emergency incident not found.")
        if incident.status in ("RESOLVED", "CANCELLED"):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Emergency incident has already ended.")

        responder = await self.emergency_repo.add_responder(incident_id, helper_id)
        incident = await self.emergency_repo.get_by_id(incident_id)

        # Broadcast live status update to active requester screen via WebSocket
        await ws_manager.broadcast_to_incident(
            incident_id=incident_id,
            data={
                "event": "helper_responding",
                "helpers_responding_count": incident.helpers_responding_count if incident else 1,
                "status": incident.status if incident else "RESPONDING",
            },
        )

        return responder

    async def update_location(self, incident_id: str, user_id: str, lat: float, lng: float) -> EmergencyIncident:
        incident = await self.emergency_repo.get_by_id(incident_id)
        if not incident:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Emergency not found.")
        if incident.requester_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized.")

        updated = await self.emergency_repo.update_location(incident_id, lat, lng)

        await ws_manager.broadcast_to_incident(
            incident_id=incident_id,
            data={"event": "location_updated", "latitude": lat, "longitude": lng},
        )
        return updated

    async def resolve_emergency(self, incident_id: str, user_id: str) -> EmergencyIncident:
        incident = await self.emergency_repo.get_by_id(incident_id)
        if not incident:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Emergency not found.")
        if incident.requester_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized.")

        resolved = await self.emergency_repo.resolve_incident(incident_id)

        await ws_manager.broadcast_to_incident(
            incident_id=incident_id,
            data={"event": "incident_resolved", "status": "RESOLVED"},
        )
        return resolved

    async def cancel_emergency(self, incident_id: str, user_id: str) -> EmergencyIncident:
        incident = await self.emergency_repo.get_by_id(incident_id)
        if not incident:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Emergency not found.")
        if incident.requester_id != user_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized.")

        cancelled = await self.emergency_repo.cancel_incident(incident_id)

        await ws_manager.broadcast_to_incident(
            incident_id=incident_id,
            data={"event": "incident_cancelled", "status": "CANCELLED"},
        )
        return cancelled

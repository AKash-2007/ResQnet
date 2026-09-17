from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database.session import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.device import NotificationDevice

class FcmTokenRequest(BaseModel):
    fcm_token: str
    device_platform: str = "Android"

router = APIRouter(prefix="/devices", tags=["Notifications & Devices"])

@router.post("/fcm-token")
async def register_fcm_token(
    req: FcmTokenRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    stmt = select(NotificationDevice).where(NotificationDevice.fcm_token == req.fcm_token)
    res = await db.execute(stmt)
    device = res.scalars().first()

    if device:
        device.user_id = current_user.id
        device.device_platform = req.device_platform
    else:
        device = NotificationDevice(
            user_id=current_user.id,
            fcm_token=req.fcm_token,
            device_platform=req.device_platform,
        )
        db.add(device)

    await db.commit()
    return {"message": "FCM device token registered successfully."}

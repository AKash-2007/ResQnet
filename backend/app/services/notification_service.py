import logging
from typing import List
import httpx
from app.core.config import settings

logger = logging.getLogger("resqnet.notifications")

class NotificationService:
    @staticmethod
    async def send_emergency_alert(
        tokens: List[str],
        emergency_type: str,
        approx_distance_meters: int,
        incident_id: str,
    ) -> int:
        """
        Sends high-priority FCM push notification to eligible helpers.
        Notification body omits exact coordinates or requester identity for privacy.
        """
        if not tokens:
            logger.info("No helper device tokens found to notify.")
            return 0

        title = f"ResQnet Emergency Alert: {emergency_type.capitalize()}"
        body = f"{emergency_type.capitalize()} emergency approximately {approx_distance_meters} m away."

        payload = {
            "notification": {
                "title": title,
                "body": body,
            },
            "data": {
                "incident_id": incident_id,
                "emergency_type": emergency_type,
                "distance_meters": str(approx_distance_meters),
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
            },
            "android": {
                "priority": "high",
                "notification": {
                    "channel_id": "resqnet_emergency_alerts",
                    "sound": "default",
                    "priority": "high",
                },
            },
        }

        if not settings.FCM_SERVER_KEY or settings.FCM_SERVER_KEY.startswith("your_"):
            logger.info(
                f"[DEMO/MOCK FCM] Dispatched alert to {len(tokens)} device tokens. "
                f"Payload: {payload['notification']['body']}"
            )
            return len(tokens)

        # Production FCM HTTP v1 / Legacy send
        successful_sends = 0
        async with httpx.AsyncClient() as client:
            for token in tokens:
                try:
                    res = await client.post(
                        "https://fcm.googleapis.com/fcm/send",
                        headers={
                            "Authorization": f"key={settings.FCM_SERVER_KEY}",
                            "Content-Type": "application/json",
                        },
                        json={"to": token, **payload},
                        timeout=5.0,
                    )
                    if res.status_code == 200:
                        successful_sends += 1
                except Exception as e:
                    logger.error(f"Failed to dispatch FCM to token: {e}")

        return successful_sends

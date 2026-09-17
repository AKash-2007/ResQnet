from typing import Optional
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from app.services.websocket_manager import ws_manager

router = APIRouter(prefix="/ws", tags=["WebSockets"])

@router.websocket("/emergencies/{incident_id}")
async def emergency_websocket_endpoint(websocket: WebSocket, incident_id: str):
    await ws_manager.connect(incident_id, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text('{"event": "pong"}')
    except WebSocketDisconnect:
        ws_manager.disconnect(incident_id, websocket)
    except Exception:
        ws_manager.disconnect(incident_id, websocket)

@router.websocket("/community/alerts")
async def community_alerts_endpoint(websocket: WebSocket, user_id: Optional[str] = None):
    conn_id = user_id or "anonymous"
    await ws_manager.connect_helper(conn_id, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text('{"event": "pong"}')
    except WebSocketDisconnect:
        ws_manager.disconnect_helper(conn_id, websocket)
    except Exception:
        ws_manager.disconnect_helper(conn_id, websocket)

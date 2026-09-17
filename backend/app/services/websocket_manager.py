from typing import Dict, List
import json
from fastapi import WebSocket

class WebSocketManager:
    def __init__(self):
        # Maps incident_id to a list of connected WebSockets (requester & responders)
        self.active_connections: Dict[str, List[WebSocket]] = {}
        # Maps user_id to list of connected WebSockets for active helpers
        self.helper_connections: Dict[str, List[WebSocket]] = {}
        # List of community broadcast WebSockets
        self.community_connections: List[WebSocket] = []

    async def connect(self, incident_id: str, websocket: WebSocket):
        await websocket.accept()
        if incident_id not in self.active_connections:
            self.active_connections[incident_id] = []
        self.active_connections[incident_id].append(websocket)

    def disconnect(self, incident_id: str, websocket: WebSocket):
        if incident_id in self.active_connections:
            if websocket in self.active_connections[incident_id]:
                self.active_connections[incident_id].remove(websocket)
            if not self.active_connections[incident_id]:
                del self.active_connections[incident_id]

    async def connect_helper(self, user_id: str, websocket: WebSocket):
        await websocket.accept()
        if user_id not in self.helper_connections:
            self.helper_connections[user_id] = []
        self.helper_connections[user_id].append(websocket)
        self.community_connections.append(websocket)

    def disconnect_helper(self, user_id: str, websocket: WebSocket):
        if user_id in self.helper_connections:
            if websocket in self.helper_connections[user_id]:
                self.helper_connections[user_id].remove(websocket)
            if not self.helper_connections[user_id]:
                del self.helper_connections[user_id]
        if websocket in self.community_connections:
            self.community_connections.remove(websocket)

    def disconnect_user(self, user_id: str):
        if user_id in self.helper_connections:
            for sock in list(self.helper_connections[user_id]):
                if sock in self.community_connections:
                    self.community_connections.remove(sock)
                try:
                    sock.close()
                except Exception:
                    pass
            del self.helper_connections[user_id]

    async def broadcast_to_incident(self, incident_id: str, data: dict):
        if incident_id in self.active_connections:
            message = json.dumps(data)
            dead_connections = []
            for connection in self.active_connections[incident_id]:
                try:
                    await connection.send_text(message)
                except Exception:
                    dead_connections.append(connection)
            for dead in dead_connections:
                self.disconnect(incident_id, dead)

    async def broadcast_emergency_to_helpers(
        self,
        helper_user_ids: List[str],
        data: dict,
        exclude_user_id: Optional[str] = None,
    ):
        """
        Broadcasts emergency alert strictly to verified eligible helpers within radius.
        Guarantees that the requester who triggered the alert and any users with
        available_to_help disabled NEVER receive the alert notification.
        """
        message = json.dumps(data)
        sent_sockets = set()

        # Strict target list excluding the requester
        target_helpers = [uid for uid in helper_user_ids if uid != exclude_user_id]

        # ONLY send to targeted, eligible helpers with active available_to_help connections
        for user_id in target_helpers:
            if user_id in self.helper_connections:
                for sock in list(self.helper_connections[user_id]):
                    if sock not in sent_sockets:
                        sent_sockets.add(sock)
                        try:
                            await sock.send_text(message)
                        except Exception:
                            pass

ws_manager = WebSocketManager()

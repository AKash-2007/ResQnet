from contextlib import asynccontextmanager
from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.auth import router as auth_router
from app.api.v1.users import router as users_router
from app.api.v1.emergencies import router as emergencies_router
from app.api.v1.helpers import router as helpers_router
from app.api.v1.nearby import router as nearby_router
from app.api.v1.notifications import router as notifications_router
from app.api.v1.websocket import router as ws_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Auto-create tables on startup (works seamlessly for SQLite dev & PostgreSQL)
    from app.database.session import engine, Base
    import app.models  # noqa
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield

app = FastAPI(
    title="ResQnet Community Emergency Assistance API",
    description="Backend API for ResQnet: community emergency alerts, PostGIS radius queries, and real-time updates.",
    version="1.0.0",
    lifespan=lifespan,
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health Check Endpoint
@app.get("/health", status_code=status.HTTP_200_OK, tags=["Health"])
async def health_check():
    return {
        "status": "healthy",
        "service": "ResQnet API",
        "environment": settings.ENVIRONMENT,
    }

# Include API v1 Routers
api_v1_prefix = "/api/v1"
app.include_router(auth_router, prefix=api_v1_prefix)
app.include_router(users_router, prefix=api_v1_prefix)
app.include_router(emergencies_router, prefix=api_v1_prefix)
app.include_router(helpers_router, prefix=api_v1_prefix)
app.include_router(nearby_router, prefix=api_v1_prefix)
app.include_router(notifications_router, prefix=api_v1_prefix)
app.include_router(ws_router, prefix=api_v1_prefix)

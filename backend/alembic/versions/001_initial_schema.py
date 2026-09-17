"""Initial schema with PostGIS support

Revision ID: 001_initial_schema
Revises: 
Create Date: 2026-09-16 00:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = '001_initial_schema'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    # Enable PostGIS extension if available
    op.execute("CREATE EXTENSION IF NOT EXISTS postgis;")

    # Users Table
    op.create_table(
        'users',
        sa.Column('id', sa.String(), primary_key=True),
        sa.Column('email', sa.String(), nullable=False, unique=True),
        sa.Column('full_name', sa.String(), nullable=False),
        sa.Column('gender', sa.String(), nullable=False, server_default='Not specified'),
        sa.Column('hashed_password', sa.String(), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index('ix_users_email', 'users', ['email'])

    # Profiles Table
    op.create_table(
        'profiles',
        sa.Column('id', sa.String(), primary_key=True),
        sa.Column('user_id', sa.String(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, unique=True),
        sa.Column('available_to_help', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('language', sa.String(), nullable=False, server_default='en'),
        sa.Column('theme_mode', sa.String(), nullable=False, server_default='system'),
        sa.Column('last_known_latitude', sa.Float(), nullable=True),
        sa.Column('last_known_longitude', sa.Float(), nullable=True),
        sa.Column('last_location_updated_at', sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index('ix_profiles_available_to_help', 'profiles', ['available_to_help'])

    # Emergency Incidents Table
    op.create_table(
        'emergency_incidents',
        sa.Column('id', sa.String(), primary_key=True),
        sa.Column('requester_id', sa.String(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('emergency_type', sa.String(), nullable=False),
        sa.Column('priority', sa.String(), nullable=False, server_default='HIGH'),
        sa.Column('status', sa.String(), nullable=False, server_default='ACTIVE'),
        sa.Column('latitude', sa.Float(), nullable=False),
        sa.Column('longitude', sa.Float(), nullable=False),
        sa.Column('address_hint', sa.String(), nullable=True),
        sa.Column('helpers_notified_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('helpers_responding_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('resolved_at', sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index('ix_incidents_requester_id', 'emergency_incidents', ['requester_id'])
    op.create_index('ix_incidents_status', 'emergency_incidents', ['status'])

    # Emergency Responders Table
    op.create_table(
        'emergency_responders',
        sa.Column('id', sa.String(), primary_key=True),
        sa.Column('incident_id', sa.String(), sa.ForeignKey('emergency_incidents.id', ondelete='CASCADE'), nullable=False),
        sa.Column('helper_id', sa.String(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('status', sa.String(), nullable=False, server_default='EN_ROUTE'),
        sa.Column('responded_at', sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index('ix_responders_incident_id', 'emergency_responders', ['incident_id'])
    op.create_index('ix_responders_helper_id', 'emergency_responders', ['helper_id'])

    # Notification Devices Table
    op.create_table(
        'notification_devices',
        sa.Column('id', sa.String(), primary_key=True),
        sa.Column('user_id', sa.String(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('fcm_token', sa.String(), nullable=False, unique=True),
        sa.Column('device_platform', sa.String(), nullable=False, server_default='Android'),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index('ix_devices_fcm_token', 'notification_devices', ['fcm_token'])

    # Refresh Tokens Table
    op.create_table(
        'refresh_tokens',
        sa.Column('id', sa.String(), primary_key=True),
        sa.Column('user_id', sa.String(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('token_hash', sa.String(), nullable=False),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('revoked', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index('ix_refresh_tokens_token_hash', 'refresh_tokens', ['token_hash'])

    # Audit Logs Table
    op.create_table(
        'audit_logs',
        sa.Column('id', sa.String(), primary_key=True),
        sa.Column('action', sa.String(), nullable=False),
        sa.Column('actor_id', sa.String(), nullable=True),
        sa.Column('target_id', sa.String(), nullable=True),
        sa.Column('details_json', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index('ix_audit_action', 'audit_logs', ['action'])

def downgrade() -> None:
    op.drop_table('audit_logs')
    op.drop_table('refresh_tokens')
    op.drop_table('notification_devices')
    op.drop_table('emergency_responders')
    op.drop_table('emergency_incidents')
    op.drop_table('profiles')
    op.drop_table('users')

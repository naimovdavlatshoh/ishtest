"""add profile views_count

Revision ID: add_profile_views
Revises: add_chat_tables
Create Date: 2026-02-12

"""
from alembic import op
import sqlalchemy as sa


revision = 'add_profile_views'
down_revision = 'add_chat_tables'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        'profiles',
        sa.Column('views_count', sa.Integer(), nullable=False, server_default=sa.text('0'))
    )


def downgrade() -> None:
    op.drop_column('profiles', 'views_count')

"""add saved_jobs table

Revision ID: add_saved_jobs
Revises: add_profile_new_fields
Create Date: 2026-01-16 20:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'add_saved_jobs'
down_revision = 'add_profile_fields'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create saved_jobs table
    op.create_table(
        'saved_jobs',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('job_id', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.ForeignKeyConstraint(['job_id'], ['jobs.id'], ),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id', 'job_id', name='uq_user_job')
    )
    op.create_index(op.f('ix_saved_jobs_id'), 'saved_jobs', ['id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_saved_jobs_id'), table_name='saved_jobs')
    op.drop_table('saved_jobs')

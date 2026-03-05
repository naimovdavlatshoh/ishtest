"""add profile new fields

Revision ID: add_profile_fields
Revises: db657ed21eba
Create Date: 2026-01-20 20:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_profile_fields'
down_revision = 'db657ed21eba'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add new columns to profiles table
    op.add_column('profiles', sa.Column('cv_file', sa.String(500), nullable=True))
    op.add_column('profiles', sa.Column('employer_info', sa.Text(), nullable=True))
    op.add_column('profiles', sa.Column('freelancer_info', sa.Text(), nullable=True))
    op.add_column('profiles', sa.Column('job_seeker_complete', sa.Boolean(), nullable=False, server_default=sa.text('false')))
    op.add_column('profiles', sa.Column('employer_complete', sa.Boolean(), nullable=False, server_default=sa.text('false')))
    op.add_column('profiles', sa.Column('freelancer_complete', sa.Boolean(), nullable=False, server_default=sa.text('false')))
    op.add_column('profiles', sa.Column('open_to_job_seeker', sa.Boolean(), nullable=False, server_default=sa.text('false')))
    op.add_column('profiles', sa.Column('open_to_employer', sa.Boolean(), nullable=False, server_default=sa.text('false')))


def downgrade() -> None:
    # Remove columns from profiles table
    op.drop_column('profiles', 'open_to_employer')
    op.drop_column('profiles', 'open_to_job_seeker')
    op.drop_column('profiles', 'freelancer_complete')
    op.drop_column('profiles', 'employer_complete')
    op.drop_column('profiles', 'job_seeker_complete')
    op.drop_column('profiles', 'freelancer_info')
    op.drop_column('profiles', 'employer_info')
    op.drop_column('profiles', 'cv_file')

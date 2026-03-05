"""add company_members table

Revision ID: add_company_members
Revises: add_saved_jobs
Create Date: 2026-01-20 21:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'add_company_members'
down_revision = 'add_saved_jobs'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create company_member_role enum
    op.execute("CREATE TYPE companymemberrole AS ENUM ('owner', 'member')")
    
    # Create company_members table
    op.create_table(
        'company_members',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('company_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('role', postgresql.ENUM('owner', 'member', name='companymemberrole', create_type=False), nullable=False, server_default='member'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['company_id'], ['companies.id'], ),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('company_id', 'user_id', name='_company_user_uc')
    )
    op.create_index(op.f('ix_company_members_id'), 'company_members', ['id'], unique=False)
    
    # Create CompanyMember entries for existing companies (owners)
    op.execute("""
        INSERT INTO company_members (company_id, user_id, role, created_at)
        SELECT id, owner_id, 'owner', created_at
        FROM companies
    """)


def downgrade() -> None:
    op.drop_index(op.f('ix_company_members_id'), table_name='company_members')
    op.drop_table('company_members')
    op.execute("DROP TYPE IF EXISTS companymemberrole")

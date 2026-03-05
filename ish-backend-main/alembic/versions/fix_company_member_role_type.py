"""fix company_member role type from enum to string

Revision ID: fix_company_member_role
Revises: add_company_members
Create Date: 2026-01-20 22:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'fix_company_member_role'
down_revision = 'add_company_members'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Change role column from enum to varchar
    # First, add a new varchar column
    op.add_column('company_members', sa.Column('role_new', sa.String(20), nullable=True))
    
    # Copy data from enum to varchar (convert to lowercase)
    op.execute("""
        UPDATE company_members 
        SET role_new = LOWER(role::text)
    """)
    
    # Drop the old enum column
    op.drop_column('company_members', 'role')
    
    # Rename the new column to role
    op.alter_column('company_members', 'role_new', new_column_name='role', nullable=False)
    
    # Set default value
    op.alter_column('company_members', 'role', server_default='member')
    
    # Drop the enum type (optional, but clean)
    op.execute("DROP TYPE IF EXISTS companymemberrole")


def downgrade() -> None:
    # Recreate enum type
    op.execute("CREATE TYPE companymemberrole AS ENUM ('owner', 'member')")
    
    # Add enum column
    op.add_column('company_members', sa.Column('role_enum', sa.Enum('owner', 'member', name='companymemberrole'), nullable=True))
    
    # Copy data from varchar to enum
    op.execute("""
        UPDATE company_members 
        SET role_enum = role::companymemberrole
    """)
    
    # Drop varchar column
    op.drop_column('company_members', 'role')
    
    # Rename enum column
    op.alter_column('company_members', 'role_enum', new_column_name='role', nullable=False)
    op.alter_column('company_members', 'role', server_default=sa.text("'member'::companymemberrole"))

"""Normalize userrole enum to lowercase ('user', 'admin')

Revision ID: normalize_userrole_lower
Revises: add_chat_invitations
Create Date: 2026-02-14

Standard: DB enum userrole uses lowercase to match initial migration and app code.
Converts existing 'USER'/'ADMIN' values to 'user'/'admin' if present.
"""
from alembic import op


revision = 'normalize_userrole_lower'
down_revision = 'add_chat_invitations'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Drop default so PostgreSQL can change column type (default can't be auto-cast)
    op.execute("ALTER TABLE users ALTER COLUMN role DROP DEFAULT")
    op.execute("ALTER TYPE userrole RENAME TO userrole_old")
    op.execute("CREATE TYPE userrole AS ENUM ('user', 'admin')")
    op.execute(
        "ALTER TABLE users ALTER COLUMN role TYPE userrole "
        "USING LOWER(role::text)::userrole"
    )
    op.execute("ALTER TABLE users ALTER COLUMN role SET DEFAULT 'user'::userrole")
    op.execute("DROP TYPE userrole_old")


def downgrade() -> None:
    op.execute("ALTER TABLE users ALTER COLUMN role DROP DEFAULT")
    op.execute("ALTER TYPE userrole RENAME TO userrole_old")
    op.execute("CREATE TYPE userrole AS ENUM ('user', 'admin')")
    op.execute(
        "ALTER TABLE users ALTER COLUMN role TYPE userrole "
        "USING role::text::userrole"
    )
    op.execute("ALTER TABLE users ALTER COLUMN role SET DEFAULT 'user'::userrole")
    op.execute("DROP TYPE userrole_old")

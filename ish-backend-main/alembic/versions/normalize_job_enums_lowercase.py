"""Normalize jobstatus enum to lowercase ('draft', 'active', 'closed')

Revision ID: normalize_job_enums
Revises: add_telegram_auth
Create Date: 2026-02-23

Standard: DB enum jobstatus uses lowercase to match initial migration and PgEnum values_callable.
Converts existing uppercase values (e.g. ACTIVE -> active) if present.
"""
from alembic import op


revision = 'normalize_job_enums'
down_revision = 'add_telegram_auth'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute("ALTER TABLE jobs ALTER COLUMN status DROP DEFAULT")
    op.execute("ALTER TYPE jobstatus RENAME TO jobstatus_old")
    op.execute("CREATE TYPE jobstatus AS ENUM ('draft', 'active', 'closed')")
    op.execute(
        "ALTER TABLE jobs ALTER COLUMN status TYPE jobstatus "
        "USING LOWER(status::text)::jobstatus"
    )
    op.execute("ALTER TABLE jobs ALTER COLUMN status SET DEFAULT 'draft'::jobstatus")
    op.execute("DROP TYPE jobstatus_old")


def downgrade() -> None:
    op.execute("ALTER TABLE jobs ALTER COLUMN status DROP DEFAULT")
    op.execute("ALTER TYPE jobstatus RENAME TO jobstatus_old")
    op.execute("CREATE TYPE jobstatus AS ENUM ('draft', 'active', 'closed')")
    op.execute(
        "ALTER TABLE jobs ALTER COLUMN status TYPE jobstatus "
        "USING status::text::jobstatus"
    )
    op.execute("ALTER TABLE jobs ALTER COLUMN status SET DEFAULT 'draft'::jobstatus")
    op.execute("DROP TYPE jobstatus_old")

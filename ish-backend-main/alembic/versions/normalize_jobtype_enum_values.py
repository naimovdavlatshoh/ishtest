"""Normalize jobtype enum to value strings ('full-time', 'part-time', ...)

Revision ID: normalize_jobtype
Revises: normalize_job_enums
Create Date: 2026-02-23

Converts DB values from Python enum names (FULL_TIME, PART_TIME, ...)
to enum values (full-time, part-time, ...) so PgEnum values_callable works on read.
"""
from alembic import op


revision = 'normalize_jobtype'
down_revision = 'normalize_job_enums'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute("ALTER TYPE jobtype RENAME TO jobtype_old")
    op.execute(
        "CREATE TYPE jobtype AS ENUM ('full-time', 'part-time', 'contract', 'internship', 'remote')"
    )
    op.execute("""
        ALTER TABLE jobs ALTER COLUMN job_type TYPE jobtype USING (
            CASE job_type::text
                WHEN 'FULL_TIME' THEN 'full-time'::jobtype
                WHEN 'PART_TIME' THEN 'part-time'::jobtype
                WHEN 'CONTRACT' THEN 'contract'::jobtype
                WHEN 'INTERNSHIP' THEN 'internship'::jobtype
                WHEN 'REMOTE' THEN 'remote'::jobtype
                ELSE job_type::text::jobtype
            END
        )
    """)
    op.execute("DROP TYPE jobtype_old")


def downgrade() -> None:
    op.execute("ALTER TYPE jobtype RENAME TO jobtype_old")
    op.execute(
        "CREATE TYPE jobtype AS ENUM ('full-time', 'part-time', 'contract', 'internship', 'remote')"
    )
    op.execute(
        "ALTER TABLE jobs ALTER COLUMN job_type TYPE jobtype USING job_type::text::jobtype"
    )
    op.execute("DROP TYPE jobtype_old")

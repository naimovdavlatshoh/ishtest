"""Normalize companysize enum to value strings ('1-10', '11-50', ...)

Revision ID: normalize_companysize
Revises: normalize_jobtype
Create Date: 2026-02-23

Converts DB values from Python enum names (SIZE_1_10, SIZE_11_50, ...)
to enum values ('1-10', '11-50', ...) so PgEnum values_callable works on read.
"""
from alembic import op


revision = 'normalize_companysize'
down_revision = 'normalize_jobtype'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute("ALTER TYPE companysize RENAME TO companysize_old")
    op.execute(
        "CREATE TYPE companysize AS ENUM ('1-10', '11-50', '51-200', '201-500', '500+')"
    )
    op.execute("""
        ALTER TABLE companies ALTER COLUMN size TYPE companysize USING (
            CASE size::text
                WHEN 'SIZE_1_10' THEN '1-10'::companysize
                WHEN 'SIZE_11_50' THEN '11-50'::companysize
                WHEN 'SIZE_51_200' THEN '51-200'::companysize
                WHEN 'SIZE_201_500' THEN '201-500'::companysize
                WHEN 'SIZE_500_PLUS' THEN '500+'::companysize
                ELSE size::text::companysize
            END
        )
    """)
    op.execute("DROP TYPE companysize_old")


def downgrade() -> None:
    op.execute("ALTER TYPE companysize RENAME TO companysize_old")
    op.execute(
        "CREATE TYPE companysize AS ENUM ('1-10', '11-50', '51-200', '201-500', '500+')"
    )
    op.execute(
        "ALTER TABLE companies ALTER COLUMN size TYPE companysize USING size::text::companysize"
    )
    op.execute("DROP TYPE companysize_old")

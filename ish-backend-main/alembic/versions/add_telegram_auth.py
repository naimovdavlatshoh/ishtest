"""Add telegram_id to users and telegram_codes table

Revision ID: add_telegram_auth
Revises: normalize_userrole_lower
Create Date: 2026-02-22

"""
from alembic import op
import sqlalchemy as sa


revision = 'add_telegram_auth'
down_revision = 'normalize_userrole_lower'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('users', sa.Column('telegram_id', sa.String(50), nullable=True))
    op.create_index(op.f('ix_users_telegram_id'), 'users', ['telegram_id'], unique=True)

    op.create_table(
        'telegram_codes',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('code_hash', sa.String(64), nullable=False),
        sa.Column('telegram_id', sa.String(50), nullable=False),
        sa.Column('purpose', sa.String(20), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=True),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(op.f('ix_telegram_codes_id'), 'telegram_codes', ['id'], unique=False)
    op.create_index(op.f('ix_telegram_codes_code_hash'), 'telegram_codes', ['code_hash'], unique=False)
    op.create_index(op.f('ix_telegram_codes_telegram_id'), 'telegram_codes', ['telegram_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_telegram_codes_telegram_id'), table_name='telegram_codes')
    op.drop_index(op.f('ix_telegram_codes_code_hash'), table_name='telegram_codes')
    op.drop_index(op.f('ix_telegram_codes_id'), table_name='telegram_codes')
    op.drop_table('telegram_codes')

    op.drop_index(op.f('ix_users_telegram_id'), table_name='users')
    op.drop_column('users', 'telegram_id')

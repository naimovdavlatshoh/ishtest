"""Add chat_invitations and make conversation.application_id nullable (direct chats)

Revision ID: add_chat_invitations
Revises: add_profile_views
Create Date: 2026-02-12

"""
from alembic import op
import sqlalchemy as sa


revision = 'add_chat_invitations'
down_revision = 'add_profile_views'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Make application_id nullable (for direct chats from invitations)
    op.alter_column(
        'conversations',
        'application_id',
        existing_type=sa.Integer(),
        nullable=True
    )
    # One direct conversation per (employer_id, applicant_id) when application_id IS NULL
    op.execute("""
        CREATE UNIQUE INDEX uq_direct_conversation
        ON conversations (employer_id, applicant_id)
        WHERE application_id IS NULL
    """)

    # Chat invitations table
    op.create_table(
        'chat_invitations',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('from_user_id', sa.Integer(), nullable=False),
        sa.Column('to_user_id', sa.Integer(), nullable=False),
        sa.Column('message', sa.Text(), nullable=True),
        sa.Column('status', sa.String(20), nullable=False, server_default='pending'),
        sa.Column('conversation_id', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(['from_user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['to_user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['conversation_id'], ['conversations.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('from_user_id', 'to_user_id', name='uq_invitation_from_to')
    )
    op.create_index(op.f('ix_chat_invitations_id'), 'chat_invitations', ['id'], unique=False)
    op.create_index(op.f('ix_chat_invitations_from_user_id'), 'chat_invitations', ['from_user_id'], unique=False)
    op.create_index(op.f('ix_chat_invitations_to_user_id'), 'chat_invitations', ['to_user_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_chat_invitations_to_user_id'), table_name='chat_invitations')
    op.drop_index(op.f('ix_chat_invitations_from_user_id'), table_name='chat_invitations')
    op.drop_index(op.f('ix_chat_invitations_id'), table_name='chat_invitations')
    op.drop_table('chat_invitations')

    op.execute("DROP INDEX IF EXISTS uq_direct_conversation")
    op.alter_column(
        'conversations',
        'application_id',
        existing_type=sa.Integer(),
        nullable=False
    )

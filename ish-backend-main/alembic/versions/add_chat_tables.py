"""Add chat tables (conversations and messages)

Revision ID: add_chat_tables
Revises: fix_company_member_role_type
Create Date: 2026-02-03

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_chat_tables'
down_revision = 'fix_company_member_role'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create message status enum (if not exists)
    op.execute("DO $$ BEGIN CREATE TYPE messagestatus AS ENUM ('sent', 'delivered', 'read'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;")
    
    # Create conversations table
    op.create_table(
        'conversations',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('application_id', sa.Integer(), nullable=False),
        sa.Column('employer_id', sa.Integer(), nullable=False),
        sa.Column('applicant_id', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(['application_id'], ['applications.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['employer_id'], ['users.id'], ),
        sa.ForeignKeyConstraint(['applicant_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('application_id', name='uq_conversation_application')
    )
    op.create_index(op.f('ix_conversations_id'), 'conversations', ['id'], unique=False)
    op.create_index(op.f('ix_conversations_employer_id'), 'conversations', ['employer_id'], unique=False)
    op.create_index(op.f('ix_conversations_applicant_id'), 'conversations', ['applicant_id'], unique=False)
    
    # Create messages table using raw SQL to avoid enum issues
    op.execute("""
        CREATE TABLE messages (
            id SERIAL PRIMARY KEY,
            conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
            sender_id INTEGER NOT NULL REFERENCES users(id),
            content TEXT NOT NULL,
            status messagestatus NOT NULL DEFAULT 'sent',
            created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
            read_at TIMESTAMP WITH TIME ZONE
        )
    """)
    op.create_index(op.f('ix_messages_id'), 'messages', ['id'], unique=False)
    op.create_index(op.f('ix_messages_conversation_id'), 'messages', ['conversation_id'], unique=False)
    op.create_index(op.f('ix_messages_sender_id'), 'messages', ['sender_id'], unique=False)
    op.create_index(op.f('ix_messages_created_at'), 'messages', ['created_at'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_messages_created_at'), table_name='messages')
    op.drop_index(op.f('ix_messages_sender_id'), table_name='messages')
    op.drop_index(op.f('ix_messages_conversation_id'), table_name='messages')
    op.drop_index(op.f('ix_messages_id'), table_name='messages')
    op.drop_table('messages')
    
    op.drop_index(op.f('ix_conversations_applicant_id'), table_name='conversations')
    op.drop_index(op.f('ix_conversations_employer_id'), table_name='conversations')
    op.drop_index(op.f('ix_conversations_id'), table_name='conversations')
    op.drop_table('conversations')
    
    op.execute("DROP TYPE messagestatus")

"""create claim model

Revision ID: c601bcc5e1bb
Revises: 266a0dc816d5
Create Date: 2022-05-19 16:50:14.248319

"""
from email.policy import default
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = 'c601bcc5e1bb'
down_revision = '266a0dc816d5'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "claims",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("protocol_id", sa.Integer(), nullable=False),
        sa.Column("initiator", sa.Text(), nullable=False),
        sa.Column("receiver", sa.Text(), nullable=False),
        sa.Column("exploit_started_at", postgresql.TIMESTAMP(), nullable=True),
        sa.Column("amount", sa.NUMERIC(precision=78), nullable=False),
        sa.Column("resources_link", sa.Text(), nullable=True),
        sa.Column("timestamp", postgresql.TIMESTAMP(), nullable=False),
        sa.PrimaryKeyConstraint("id")
    ),
    sa.ForeignKeyConstraint(
        ["protocol_id"],
        ["protocols.id"],
    )


def downgrade():
    op.drop_table("claims")

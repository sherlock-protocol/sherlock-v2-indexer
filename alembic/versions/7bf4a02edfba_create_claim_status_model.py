"""create claim status model

Revision ID: 7bf4a02edfba
Revises: c601bcc5e1bb
Create Date: 2022-06-07 20:10:11.148525

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = '7bf4a02edfba'
down_revision = 'c601bcc5e1bb'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "claim_status",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("claim_id", sa.Integer(), nullable=False),
        sa.Column("status", sa.Integer(), default=0),
        sa.Column("timestamp", postgresql.TIMESTAMP(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    ),
    sa.ForeignKeyConstraint(
        ["claim_id"],
        ["claims.id"]
    ),


def downgrade():
    op.drop_table("claim_status")

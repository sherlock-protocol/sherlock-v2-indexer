"""create payouts table

Revision ID: a616b15ef898
Revises: 7bf4a02edfba
Create Date: 2022-06-22 09:17:19.798994

"""
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

# revision identifiers, used by Alembic.
revision = "a616b15ef898"
down_revision = "7bf4a02edfba"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "claim_payouts",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("claim_id", sa.Integer(), nullable=False),
        sa.Column("tx_hash", sa.Text(), nullable=False),
        sa.Column("timestamp", postgresql.TIMESTAMP(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["claim_id"], ["claims.id"]),
        sa.UniqueConstraint("claim_id", "tx_hash"),
    )


def downgrade():
    op.drop_table("claim_payouts")

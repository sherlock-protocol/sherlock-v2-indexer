"""create stats_tvl table

Revision ID: 41805685552a
Revises: 17810e991dcc
Create Date: 2022-03-28 10:36:02.433203

"""
from alembic import op
import sqlalchemy as sa

from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "41805685552a"
down_revision = "17810e991dcc"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "stats_tvl",
        sa.Column("id", sa.BIGINT, primary_key=True),
        sa.Column("timestamp",  postgresql.TIMESTAMP(), nullable=False),
        sa.Column("block", sa.Integer(), nullable=False),
        sa.Column("value", sa.NUMERIC(precision=78), nullable=False)
    )


def downgrade():
    op.drop_table("stats_tvl")

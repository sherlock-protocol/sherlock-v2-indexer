"""Add StatsExternalCoverage

Revision ID: 88aeea0b2296
Revises: ed8fd7dd2dcb
Create Date: 2024-07-26 11:12:57.274224

"""

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

# revision identifiers, used by Alembic.
revision = "88aeea0b2296"
down_revision = "ed8fd7dd2dcb"
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table(
        "stats_external_coverage",
        sa.Column("id", sa.BIGINT(), nullable=False),
        sa.Column("timestamp", postgresql.TIMESTAMP(), nullable=False),
        sa.Column("value", sa.NUMERIC(precision=78), nullable=False),
        sa.Column("block", sa.Integer(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table("stats_external_coverage")
    # ### end Alembic commands ###

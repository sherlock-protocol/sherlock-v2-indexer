"""create stats_tvc table

Revision ID: 82b633194b0a
Revises: 7317246bb7d8
Create Date: 2022-04-12 11:23:24.369150

"""
from alembic import op
import sqlalchemy as sa

from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = '82b633194b0a'
down_revision = '7317246bb7d8'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "stats_tvc",
        sa.Column("id", sa.BIGINT, primary_key=True),
        sa.Column("timestamp",  postgresql.TIMESTAMP(), nullable=False),
        sa.Column("block", sa.Integer(), nullable=False),
        sa.Column("value", sa.NUMERIC(precision=78), nullable=False)
    )
    pass


def downgrade():
    pass

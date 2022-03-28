"""update indexer state table

Revision ID: 693951bd0b54
Revises: 41805685552a
Create Date: 2022-03-28 10:49:50.753427

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "693951bd0b54"
down_revision = "41805685552a"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("indexer_state", sa.Column("last_stats_block", sa.Integer(), nullable=False))
    op.add_column("indexer_state", sa.Column("last_stats_time", postgresql.TIMESTAMP(), nullable=False))


def downgrade():
    op.drop_column("indexer_state", "last_stats_block")
    op.drop_column("indexer_state", "last_stats_time")

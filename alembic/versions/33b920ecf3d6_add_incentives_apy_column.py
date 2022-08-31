"""add incentives_apy column

Revision ID: 33b920ecf3d6
Revises: 9563fd232d2f
Create Date: 2022-08-25 08:58:09.448640

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '33b920ecf3d6'
down_revision = 'fe1a6b4ecd8a'
branch_labels = None
depends_on = None


def upgrade():
    # TODO decide if nullable=true and server_default=None or not.
    op.add_column("stats_apy", sa.Column("incentives_apy", sa.Float(), nullable=False, server_default=sa.schema.DefaultClause("0")))
    op.add_column("indexer_state", sa.Column("incentives_apy", sa.Float(), nullable=False, server_default=sa.schema.DefaultClause("0")))


def downgrade():
    op.drop_column("stats_apy", "incentives_apy")
    op.drop_column("indexer_state", "incentives_apy")

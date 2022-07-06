"""add apy_premiums column to apy stats

Revision ID: a63fedccf9cd
Revises: 7bf4a02edfba
Create Date: 2022-07-04 13:14:19.803746

"""
import sqlalchemy as sa

from alembic import op

# revision identifiers, used by Alembic.
revision = "a63fedccf9cd"
down_revision = "7bf4a02edfba"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("stats_apy", sa.Column("premiums_apy", sa.Float(), nullable=False))


def downgrade():
    op.drop_column("stats_apy", "premiums_apy")

"""Create StatsAPY model

Revision ID: 09eccbf364b9
Revises: 82b633194b0a
Create Date: 2022-05-04 12:32:07.998705

"""
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

# revision identifiers, used by Alembic.
revision = "09eccbf364b9"
down_revision = "82b633194b0a"
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table(
        "stats_apy",
        sa.Column("id", sa.BIGINT(), nullable=False),
        sa.Column("timestamp", postgresql.TIMESTAMP(), nullable=False),
        sa.Column("value", sa.Float(), nullable=False),
        sa.Column("block", sa.Integer(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table("stats_apy")
    # ### end Alembic commands ###

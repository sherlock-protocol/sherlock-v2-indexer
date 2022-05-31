"""Additional APY and strategy balance model

Revision ID: 309b0f5de150
Revises: 266a0dc816d5
Create Date: 2022-05-31 17:05:50.534901

"""
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

# revision identifiers, used by Alembic.
revision = "309b0f5de150"
down_revision = "266a0dc816d5"
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table(
        "strategy_balances",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("address", sa.Text(), nullable=False),
        sa.Column("value", sa.NUMERIC(precision=78), nullable=False),
        sa.Column("timestamp", postgresql.TIMESTAMP(), nullable=False),
        sa.Column("block", sa.Integer(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.add_column("indexer_state", sa.Column("additional_apy", sa.Float(), server_default="0", nullable=False))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column("indexer_state", "additional_apy")
    op.drop_table("strategy_balances")
    # ### end Alembic commands ###

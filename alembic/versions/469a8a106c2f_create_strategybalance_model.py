"""Create StrategyBalance model

Revision ID: 469a8a106c2f
Revises: 7bf4a02edfba
Create Date: 2022-07-06 16:30:48.283394

"""
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

# revision identifiers, used by Alembic.
revision = "469a8a106c2f"
down_revision = "a63fedccf9cd"
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
    op.alter_column("claim_status", "status", existing_type=sa.INTEGER(), nullable=False)
    op.create_foreign_key(None, "claim_status", "claims", ["claim_id"], ["id"])
    op.create_foreign_key(None, "claims", "protocols", ["protocol_id"], ["id"])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(None, "claims", type_="foreignkey")
    op.drop_constraint(None, "claim_status", type_="foreignkey")
    op.alter_column("claim_status", "status", existing_type=sa.INTEGER(), nullable=True)
    op.drop_table("strategy_balances")
    # ### end Alembic commands ###

"""Unique protocol bytes id

Revision ID: 17810e991dcc
Revises: e93e2e0034cb
Create Date: 2022-03-23 12:17:52.700677

"""
from alembic import op

# revision identifiers, used by Alembic.
revision = "17810e991dcc"
down_revision = "e93e2e0034cb"
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_unique_constraint(None, "protocols", ["bytes_identifier"])
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint(None, "protocols", type_="unique")
    # ### end Alembic commands ###

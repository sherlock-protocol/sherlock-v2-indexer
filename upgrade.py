import importlib
import logging
import os
import re
from argparse import ArgumentParser
from datetime import datetime

import settings
from alembic import command
from alembic.config import Config

logging.basicConfig(level=logging.INFO)


def parse_args():
    """Parse CLI arguments"""
    parser = ArgumentParser()
    parser.add_argument(
        "-b", "--block", dest="block", help="Block number to start reindexing from", type=int, required=True
    )

    return parser.parse_args()


def create_new_database() -> str:
    """Creates a new database

    Returns:
        str: The name of the newly created database
    """
    logging.info("[+] Creating new database...")

    # Generate the name by apppending current timestamp
    new_db_name = "indexer_" + str(int(datetime.now().timestamp()))

    # Create db connection
    conn = settings.DB.connect()

    # End open transaction using COMMIT (cannot create databases inside transactions)
    conn.execute("commit")

    # Create the database
    conn.execute("create database " + new_db_name)
    conn.close()

    logging.info("[ ] Created database " + new_db_name)

    # Update env variable for the rest of this script's execution
    os.environ["DB_NAME"] = new_db_name

    return new_db_name


def update_env(db_name: str):
    """Update DB_NAME in .env file

    Args:
        db_name (str): New database name
    """
    logging.info("[+] Updating .env...")

    with open("./.env") as f:
        current_env = f.read()

    # Update DB_NAME field
    new_env = re.sub(r"DB_NAME=(.*)", "DB_NAME=" + db_name, current_env)

    with open("./.env", "w") as f:
        f.write(new_env)


def run_db_migrations():
    """Get DB structure up to date by running
    available database migration scripts."""
    logging.info("[+] Running DB migrations...")

    # Force reimporting settings module to use the new env variables
    importlib.reload(settings)

    config = Config("./alembic.ini")
    command.upgrade(config, "head")


def initialize_database(block_number):
    """Initialize the new database"""
    import database

    database.run(block_number)


def reindex():
    """Index events until up to date"""
    from indexer import Indexer

    indexer = Indexer()
    indexer.start()


def main():
    args = parse_args()

    # Create the new database
    db_name = create_new_database()

    # Update .env
    update_env(db_name)

    # Run migrations
    run_db_migrations()

    # Initialize database
    initialize_database(args.block)

    # Run indexer on new database until up to date
    reindex()

    # TODO: Trigger main app restart/reload


if __name__ == "__main__":
    main()

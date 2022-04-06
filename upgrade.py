import importlib
import logging
import os
import re
from argparse import ArgumentParser
from datetime import datetime
from threading import Thread
from time import sleep

import settings
from alembic import command
from alembic.config import Config

logging.basicConfig(level=logging.INFO)


def parse_args():
    """Parse CLI arguments"""
    parser = ArgumentParser()
    parser.add_argument(
        "-b",
        "--block",
        dest="block",
        help="Block number to start reindexing from",
        type=int,
        required=True,
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

    config = Config("alembic.ini")
    config.attributes["configure_logger"] = False

    command.upgrade(config, "head")


def initialize_database(block_number):
    """Initialize the new database"""
    logging.info(f"[+] Initializing the DB to block {block_number}...")

    import database

    database.run(block_number)


def reindex():
    """Index events until up to date"""
    from indexer import Indexer
    from models import IndexerState, Session

    current_block_number = settings.WEB3_WSS.eth.blockNumber
    logging.info(f"[+] Indexing until block {current_block_number}")

    indexer = Indexer()
    thread = Thread(name="Indexer", target=indexer.start)
    thread.start()

    # Wait for the DB to get up to date
    with Session() as s:
        while True:
            s.expire_all()
            state = s.query(IndexerState).first()
            logging.info(f"[+] - Last indexed block: {state.last_block}")

            if state.last_block >= current_block_number:
                break

            sleep(2)

    thread.do_run = False
    thread.join()


def run_shell_command(command: str) -> str:
    """Run a shell command an capture it's output.

    Args:
        command (str): Command to execute

    Returns:
        str: Command output
    """
    logging.debug("[ ] Executing command: " + command)
    with os.popen(command) as stream:
        output = stream.read()
        logging.debug(f"[ ] Output: \r\n{output}")

        return output


def find_indexer_pid() -> str:
    """Search indexer's process ID.

    Search is being done by looking for a process started with `python` command, by user `evert`
    in the current working directory.

    We filter resulting entries using `ps` to extract only the `python` process that
    started the `indexer.py` script.


    Returns:
        str: Indexer's process PID
    """
    command = "lsof -u acelasi -c python -d cwd -a -t -f -- ."
    output = run_shell_command(command)
    pids = re.findall(r"\d+", output)

    command = f'ps x | grep -E "{"|".join(pids)}" | grep "python [i]ndexer.py" | awk \'{{ print $1 }}\''
    output = run_shell_command(command)

    try:
        return re.match(r"\d+", output).group(0)
    except Exception:
        return None


def stop_indexer_process(pid: str):
    """Kills the indexer process, gracefuly.

    Args:
        pid (str): Process PID
    """
    logging.info(f"[+] Stopping process {pid}...")

    command = f"kill -s TERM {pid}"
    run_shell_command(command)

    # Wait for the process to exit
    while find_indexer_pid() is not None:
        sleep(2)


def start_new_indexer():
    """Start a new indexer."""
    logging.info("[+] Starting new indexer process...")

    command = "screen -d -m python indexer.py"
    run_shell_command(command)

    # Let process start
    sleep(2)

    pid = find_indexer_pid()
    if not pid:
        raise Exception("Failed starting a new indexer process!")

    logging.info(f"[+] New indexer process started {pid}")


def restart_service():
    logging.info("[+] Restarting API service...")


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

    # Fetch indexer PID
    pid = find_indexer_pid()

    if not pid:
        raise Exception("Could not find indexer PID.")

    # Kill indexer
    stop_indexer_process(pid)

    # Spawn another indexer
    start_new_indexer()

    # Restart API service
    restart_service()


if __name__ == "__main__":
    main()

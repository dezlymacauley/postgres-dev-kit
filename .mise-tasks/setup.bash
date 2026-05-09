#!/usr/bin/env bash
#MISE description="🗃️ Setup the Postgres Dev Kit"
#MISE quiet=true

#______________________________________________________________________________

# A helper function to make text in this script white and bold, 
# with a purple background
purple_white() {
    echo -e "\033[1;38;2;255;255;255;48;2;97;0;121m$1\033[0m"
}

#______________________________________________________________________________

echo
purple_white "🗃️ Creating the Postgres cluster and default database"
echo "========================================================================"

echo
purple_white "Step 1: Checking if environment variables for psql are set"

# Enable strict mode for Bash:
# `set -eu` is shorthand for `set -e -u`

# `-e` means the script should stop immediately if any command returns
# a non-zero exit code.

# `-u` means the script should stop immediately if any variables 
# are undefined.

set -eu

# These are gaurd clauses. The script will fail automatically if any of these
# environment variables are missing in `mise.toml`
: "${PSQL_LOGIN_USER_NAME:?Missing PSQL_LOGIN_USER_NAME}"
: "${PSQL_DB_NAME:?Missing PSQL_DB_NAME environment variable}"


echo
echo "✅ psql environment variables are set"


echo "________________________________________________________________________"

echo
purple_white "Step 2: Setting the Python virtual environment and Python tools"

# Remove the existing virtual environment to ensure a clean setup
# This is important if the Python version has been changed.
rm -rf .venv 

# Create Python virtual environment from `.python-version`
echo
uv venv --python "$(cat .python-version)"

# Activate the Python virtual environment and install
# Python tools like `pgcli` using the `pyproject.toml` file.

echo
uv sync 

echo "________________________________________________________________________"

echo
purple_white "Step 3: Creating the Postgres Database Cluster"


# Stop Postgres server if it is running
if pg_ctl -D .postgres status 1>/dev/null 2>/dev/null; then
    echo
    echo "⏳ Stopping the Postgres server..."
    # `-m smart` ensures a graceful shutdown if any clients are still
    # connected to the server.
    pg_ctl -D .postgres stop -m smart
    echo
else
    echo
    echo "✅ There is no Postgres server currently running."
    echo
fi

# Remove the existing Postgres cluster to ensure that the database init
# runs smoothly
rm -rf .postgres

# Initialize a new Postgres cluster using the default login user name.
initdb -D .postgres -U "$PSQL_LOGIN_USER_NAME"

# Disable checkpoint logging to reduce terminal noise
echo "log_checkpoints = off" >> .postgres/postgresql.conf

echo "________________________________________________________________________"

echo
purple_white "Step 4: Creating the default database"

# Start the Postgres server with a log file.
# Then wait until the Postgres server is ready to recieve connections 
# to avoid any issues when trying to create the default database.
echo
pg_ctl -D .postgres -l .postgres/logfile start

until pg_isready -d postgres -q; do
    sleep 1
done

# Display a message once the Postgres server is ready to receive connections
echo
echo "🐘 Postgres server is ready."
echo

# Create the default database
echo "⏳Creating the default database and default login user"
echo "- Default database: $PSQL_DB_NAME"
echo "- Default login user: $PSQL_LOGIN_USER_NAME"
echo
createdb -U "$PSQL_LOGIN_USER_NAME" "$PSQL_DB_NAME"

echo
echo "🐘 Postgres Dev Kit Setup successful"

echo
echo "========================================================================"
echo

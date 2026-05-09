#!/usr/bin/env bash
#MISE description="⚙️ Perform admin tasks database with psql "
#MISE quiet=true
#______________________________________________________________________________

# STEP: 1 => Ensure that environment variables for PSQL are available

# Fail immediately if any unset variable is used
set -eu

# This is a collection of guard clauses,
# to check that the following environment variables have been set in 
# `mise.toml` and are accessible.
: "${PSQL_LOGIN_USER_NAME:?Missing PSQL_LOGIN_USER_NAME}"
: "${PSQL_DB_NAME:?Missing PSQL_DB_NAME}"
: "${PSQL_DB_HOST:?Missing PSQL_DB_HOST}"
: "${PSQL_DB_PORT:?Missing PSQL_DB_PORT}"

#______________________________________________________________________________

# STEP: 2 => Check if a Postgres Cluster exists

# Check if the Postgres cluster exists
if [ ! -d ".postgres" ] || [ ! -f ".postgres/PG_VERSION" ]; then
    echo
    echo "❌ No Postgres cluster found."
    echo "Run this command to create a Postgres cluster:"
    echo "mise create"
    echo
    exit 1
fi

#______________________________________________________________________________

# STEP: 3 => Start the Postgres server if it is not running

if ! pg_ctl -D .postgres status 1>/dev/null 2>/dev/null; then
    pg_ctl -D .postgres -l .postgres/logfile start
fi

#______________________________________________________________________________

# STEP: 4 => Connect to the Postgres server with psql 

    echo
    echo "____________________________________________________________"
    echo "🗃️ Connecting to database: $PSQL_DB_NAME"
    echo "  - Host: $PSQL_DB_HOST"
    echo "  - Port: $PSQL_DB_PORT"
    echo "👤 via the user: $PSQL_LOGIN_USER_NAME"
    echo "_____________________________________________________________"
    echo

    psql \
        -U "$PSQL_LOGIN_USER_NAME" \
        -d "$PSQL_DB_NAME" \
        -h "$PSQL_DB_HOST" \
        -p "$PSQL_DB_PORT"

#______________________________________________________________________________

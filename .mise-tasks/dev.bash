#!/usr/bin/env bash
#MISE description="🔎 Perform query tasks with pgcli"
#MISE quiet=true
#______________________________________________________________________________

# STEP: 1 => Ensure that environment variables for PSQL are available

# Fail immediately if any unset variable is used
set -eu

# This is a collection of guard clauses,
# to check that the following environment variables have been set in 
# `mise.toml` and are accessible.
: "${PGCLI_LOGIN_USER_NAME:?Missing PGCLI_LOGIN_USER_NAME}"
: "${PGCLI_DB_NAME:?Missing PGCLI_DB_NAME}"
: "${PGCLI_DB_HOST:?Missing PGCLI_DB_HOST}"
: "${PGCLI_DB_PORT:?Missing PGCLI_DB_PORT}"
: "${PGCLI_DB_PORT:?Missing PGCLI_DB_PORT}"
: "${PGCLI_CONFIG_FILE:?Missing PGCLI_CONFIG_FILE}"

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
    echo "🗃️ Connecting to database: $PGCLI_DB_NAME"
    echo "  - Host: $PGCLI_DB_HOST"
    echo "  - Port: $PGCLI_DB_PORT"
    echo "👤 via the user: $PGCLI_LOGIN_USER_NAME"
    echo "_____________________________________________________________"
    echo

    pgcli \
        -U "$PGCLI_LOGIN_USER_NAME" \
        --pgclirc "$PGCLI_CONFIG_FILE" \
        -d "$PGCLI_DB_NAME" \
        -h "$PGCLI_DB_HOST" \
        -p "$PGCLI_DB_PORT"

#______________________________________________________________________________

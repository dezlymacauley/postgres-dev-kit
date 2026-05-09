#!/usr/bin/env bash
#MISE description="🔴 Stop the Postgres Server"
#MISE quiet=true

#______________________________________________________________________________

# A helper function to make text in this script white and bold, 
# with a purple background
purple_white() {
    echo -e "\033[1;38;2;255;255;255;48;2;97;0;121m$1\033[0m"
}

#______________________________________________________________________________

echo
purple_white "🔴 Stopping the Postgres Server"
echo "========================================================================"

echo
if pg_ctl -D .postgres status 1>/dev/null 2>/dev/null; then
    echo "⏳ Stopping the Postgres server..."
    # `-m smart` will wait ensure that this is a graceful shutdown.
    # It will wait for all clients to disconnect from the database before
    # shutting down.
    pg_ctl -D .postgres stop -m smart
else
    echo "There is no Postgres server currently running."
fi

echo
echo "========================================================================"
echo

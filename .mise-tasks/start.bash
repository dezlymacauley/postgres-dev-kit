#!/usr/bin/env bash
#MISE description="🟢 Start the Postgres Server"
#MISE quiet=true

#______________________________________________________________________________

# A helper function to make text in this script white and bold, 
# with a purple background
purple_white() {
    echo -e "\033[1;38;2;255;255;255;48;2;97;0;121m$1\033[0m"
}

#______________________________________________________________________________

echo
purple_white "🟢 Starting the Postgres Server"
echo "========================================================================"

# Check if the Postgres cluster exists
if [ ! -d ".postgres" ] || [ ! -f ".postgres/PG_VERSION" ]; then
    echo
    echo "❌ No Postgres cluster found."
    echo "Run the 'mise setup' command first."
    echo
    exit 0
fi

echo
# Check if already running
if pg_ctl -D .postgres status 1>/dev/null 2>/dev/null; then
    echo "✅ The Postgres server is already running."
else
    echo "⏳ Starting the Postgres server..."
    pg_ctl -D .postgres -l .postgres/logfile start
fi

echo
echo "========================================================================"
echo

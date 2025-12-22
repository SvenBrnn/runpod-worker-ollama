#!/bin/bash

cleanup() {
    echo "Cleaning up..."
    pkill -P $$ # Kill all child processes of the current script
    exit 0
}

# Trap exit signals and call the cleanup function
trap cleanup SIGINT SIGTERM

# Kill any existing inflect processes
pgrep inflect | xargs kill

# Start the inflect server and log its output
inflect serve -d /runpod-volume/$INFLECT_SYSTEM_NAME 2>&1 | tee inflect.server.log &
INFLECT_PID=$! # Store the process ID (PID) of the background command

check_server_is_running() {
    echo "Checking if server is running..."
    if cat inflect.server.log | grep -q "Server running at"; then
        return 0 # Success
    else
        return 1 # Failure
    fi
}

# Wait for the server to start
while ! check_server_is_running; do
    sleep 5
done

python -u handler.py $1

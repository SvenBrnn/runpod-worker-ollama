#!/bin/bash

cleanup() {
    echo "Cleaning up..."
    pkill -P $$ # Kill all child processes of the current script
    exit 0
}

# Trap exit signals and call the cleanup function
trap cleanup SIGINT SIGTERM

# Kill any existing ollama processes
# pgrep ollama | xargs kill
pkill -f ollama
sleep 1

# Start the ollama server and log its output
ollama serve 2>&1 | tee ollama.server.log &
OLLAMA_PID=$! # Store the process ID (PID) of the background command

check_server_is_running() {
    echo "Checking if server is running..."
    if curl -s -f http://localhost:11434/ > /dev/null; then
        return 0 # Success
    else
        return 1 # Failure
    fi
}

# Wait for the server to start
while ! check_server_is_running; do
    sleep 2
done
# IF $MODEL_NAME is set, make sure to pull the model, else just skip
if [ -z "$OLLAMA_MODEL_NAME" ]; then
    echo "No model name provided. Skipping model pull..."
else
    echo "Pulling model $OLLAMA_MODEL_NAME..."
    ollama pull $OLLAMA_MODEL_NAME
fi

python -u handler.py $1
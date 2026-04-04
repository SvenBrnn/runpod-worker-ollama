#!/bin/bash

wait_for_ollama() {
    local timeout_seconds=$1

    if [ -z "$timeout_seconds" ] || ! [[ "$timeout_seconds" =~ ^[0-9]+$ ]] || [ "$timeout_seconds" -lt 1 ]; then
        timeout_seconds=15
    fi

    local max_attempts=$timeout_seconds
    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if curl -s -f http://localhost:11434/ > /dev/null; then
            echo "Ollama server is ready."
            return 0
        fi
        echo "Waiting for Ollama server... (attempt $((attempt + 1))/$max_attempts)"
        sleep 1
        ((attempt++))
    done
    echo "Error: Ollama server failed to start within $max_attempts seconds." >&2
    kill $OLLAMA_PID 2>/dev/null
    exit 1
}

# Check if MODEL_NAMES is empty and exit if so
if [ ${#MODEL_NAMES[@]} -eq 0 ]; then
    echo "Error: MODEL_NAMES array is empty. No models specified to preload." >&2
    exit 1
fi

# Start the Ollama server in the background
echo "Starting Ollama server to preload models: $MODEL_NAMES"
ollama serve &

# Capture the PID of the Ollama server
OLLAMA_PID=$!

# Wait for the server to be ready (adjust if necessary)
echo "Waiting for Ollama server to start..."
wait_for_ollama 10

# Split the comma-separated model names into an array
IFS=',' read -r -a MODELS <<< "$MODEL_NAMES"

# Loop through each model and pull it
for MODEL_NAME in "${MODELS[@]}"; do
  echo "Pulling model: $MODEL_NAME"
  if ollama pull "$MODEL_NAME"; then
    echo "Successfully pulled model: $MODEL_NAME"
  else
    echo "Failed to pull model: $MODEL_NAME"
    kill $OLLAMA_PID
    exit 1
  fi
done

# Stop the Ollama server
echo "Stopping Ollama server..."
kill $OLLAMA_PID

# Wait for the server to terminate
wait $OLLAMA_PID

echo "Model preloading complete."

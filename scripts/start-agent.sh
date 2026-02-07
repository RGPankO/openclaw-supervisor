#!/bin/bash
# Start an OpenClaw agent
# Usage: ./start-agent.sh <name> <port>

NAME=$1
PORT=$2

if [ -z "$NAME" ]; then
    echo "Usage: $0 <name> [port]"
    exit 1
fi

# Check if profile exists
if [ ! -d "$HOME/.openclaw-$NAME" ]; then
    echo "Error: Profile '$NAME' does not exist"
    exit 1
fi

echo "Starting agent: $NAME"

if [ -n "$PORT" ]; then
    openclaw --profile "$NAME" gateway start --port "$PORT"
else
    openclaw --profile "$NAME" gateway start
fi

echo "✅ Agent '$NAME' started"

#!/bin/bash
# Start an OpenClaw agent via launchctl
# Usage: ./start-agent.sh <name>

NAME=$1

if [ -z "$NAME" ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

PLIST="$HOME/Library/LaunchAgents/ai.openclaw.${NAME}.plist"

if [ ! -f "$PLIST" ]; then
    echo "Error: No launchd service found for '$NAME'"
    echo "Expected: $PLIST"
    echo "Install first: openclaw --profile $NAME gateway install"
    exit 1
fi

echo "Starting agent: $NAME"
launchctl load "$PLIST" 2>&1

echo "✅ Agent '$NAME' started"

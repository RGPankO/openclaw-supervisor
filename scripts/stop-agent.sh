#!/bin/bash
# Stop an OpenClaw agent via launchctl
# Usage: ./stop-agent.sh <name>

NAME=$1

if [ -z "$NAME" ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

PLIST="$HOME/Library/LaunchAgents/ai.openclaw.${NAME}.plist"

if [ ! -f "$PLIST" ]; then
    echo "Error: No launchd service found for '$NAME'"
    echo "Expected: $PLIST"
    exit 1
fi

echo "Stopping agent: $NAME"
launchctl unload "$PLIST" 2>&1

echo "✅ Agent '$NAME' stopped"

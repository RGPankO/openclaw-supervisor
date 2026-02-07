#!/bin/bash
# Restart an OpenClaw agent
# Usage: ./restart-agent.sh <name>

NAME=$1

if [ -z "$NAME" ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

echo "Restarting agent: $NAME"

openclaw --profile "$NAME" gateway restart

echo "✅ Agent '$NAME' restarted"

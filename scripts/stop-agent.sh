#!/bin/bash
# Stop an OpenClaw agent
# Usage: ./stop-agent.sh <name>

NAME=$1

if [ -z "$NAME" ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

echo "Stopping agent: $NAME"

openclaw --profile "$NAME" gateway stop

echo "✅ Agent '$NAME' stopped"

#!/bin/bash
# Show status of all agents
# Usage: ./status.sh [instances-file]

INSTANCES_FILE=${1:-"${SUPERVISOR_WORKSPACE:-$HOME/.openclaw/workspace-supervisor}/INSTANCES.yaml"}

if [ ! -f "$INSTANCES_FILE" ]; then
    echo "No instances file found"
    exit 0
fi

echo "📊 Agent Status — $(date '+%Y-%m-%d %H:%M')"
echo ""

while IFS= read -r line; do
    if [[ $line =~ name:\ *(.+) ]]; then
        CURRENT_NAME="${BASH_REMATCH[1]}"
    fi
    if [[ $line =~ port:\ *([0-9]+) ]]; then
        CURRENT_PORT="${BASH_REMATCH[1]}"

        if [ -n "$CURRENT_NAME" ]; then
            if curl -sf "http://127.0.0.1:${CURRENT_PORT}/health" > /dev/null 2>&1; then
                echo "✅ $CURRENT_NAME (port $CURRENT_PORT) — running"
            else
                # Check if service exists but isn't responding
                PLIST="$HOME/Library/LaunchAgents/ai.openclaw.${CURRENT_NAME}.plist"
                if [ -f "$PLIST" ] && launchctl list | grep -q "ai.openclaw.${CURRENT_NAME}"; then
                    echo "⚠️  $CURRENT_NAME (port $CURRENT_PORT) — service loaded but not responding"
                else
                    echo "⏹️  $CURRENT_NAME (port $CURRENT_PORT) — stopped"
                fi
            fi

            CURRENT_NAME=""
            CURRENT_PORT=""
        fi
    fi
done < "$INSTANCES_FILE"

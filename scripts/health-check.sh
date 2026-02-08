#!/bin/bash
# Health check all agents in INSTANCES.yaml
# Usage: ./health-check.sh [instances-file]

INSTANCES_FILE=${1:-"${SUPERVISOR_WORKSPACE:-$HOME/.openclaw/workspace-supervisor}/INSTANCES.yaml"}

if [ ! -f "$INSTANCES_FILE" ]; then
    echo "No instances file found at $INSTANCES_FILE"
    exit 0
fi

echo "🏥 Health Check — $(date '+%Y-%m-%d %H:%M')"
echo ""

TOTAL=0
HEALTHY=0
UNHEALTHY=0

while IFS= read -r line; do
    if [[ $line =~ name:\ *(.+) ]]; then
        CURRENT_NAME="${BASH_REMATCH[1]}"
    fi
    if [[ $line =~ port:\ *([0-9]+) ]]; then
        CURRENT_PORT="${BASH_REMATCH[1]}"

        if [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_PORT" ]; then
            TOTAL=$((TOTAL + 1))

            if curl -sf "http://127.0.0.1:${CURRENT_PORT}/health" > /dev/null 2>&1; then
                echo "✅ $CURRENT_NAME (port $CURRENT_PORT) — healthy"
                HEALTHY=$((HEALTHY + 1))
            else
                echo "❌ $CURRENT_NAME (port $CURRENT_PORT) — UNHEALTHY"
                UNHEALTHY=$((UNHEALTHY + 1))
            fi

            CURRENT_NAME=""
            CURRENT_PORT=""
        fi
    fi
done < "$INSTANCES_FILE"

echo ""
echo "Summary: $HEALTHY/$TOTAL healthy"

if [ $UNHEALTHY -gt 0 ]; then
    exit 1
fi

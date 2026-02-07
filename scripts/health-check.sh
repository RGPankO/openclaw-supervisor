#!/bin/bash
# Health check all agents in INSTANCES.yaml
# Usage: ./health-check.sh [instances-file]

INSTANCES_FILE=${1:-"$HOME/.openclaw-supervisor/workspace/INSTANCES.yaml"}

if [ ! -f "$INSTANCES_FILE" ]; then
    echo "No instances file found at $INSTANCES_FILE"
    exit 0
fi

# Parse YAML (simple grep-based, assumes flat structure)
# For production, use yq or python

echo "🏥 Health Check — $(date '+%Y-%m-%d %H:%M')"
echo ""

TOTAL=0
HEALTHY=0
UNHEALTHY=0

# Extract instance names and ports
while IFS= read -r line; do
    if [[ $line =~ name:\ *(.+) ]]; then
        CURRENT_NAME="${BASH_REMATCH[1]}"
    fi
    if [[ $line =~ port:\ *([0-9]+) ]]; then
        CURRENT_PORT="${BASH_REMATCH[1]}"
        
        if [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_PORT" ]; then
            TOTAL=$((TOTAL + 1))
            
            # Check if gateway is responding
            if openclaw --profile "$CURRENT_NAME" gateway health > /dev/null 2>&1; then
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

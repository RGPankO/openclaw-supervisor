#!/bin/bash
# Show status of all agents
# Usage: ./status.sh [instances-file]

INSTANCES_FILE=${1:-"$HOME/.openclaw-supervisor/workspace/INSTANCES.yaml"}

if [ ! -f "$INSTANCES_FILE" ]; then
    echo "No instances file found"
    echo "Create agents first, or check $INSTANCES_FILE"
    exit 0
fi

echo "📊 Agent Status — $(date '+%Y-%m-%d %H:%M')"
echo ""

# Parse and display
while IFS= read -r line; do
    if [[ $line =~ name:\ *(.+) ]]; then
        CURRENT_NAME="${BASH_REMATCH[1]}"
    fi
    if [[ $line =~ port:\ *([0-9]+) ]]; then
        CURRENT_PORT="${BASH_REMATCH[1]}"
    fi
    if [[ $line =~ status:\ *(.+) ]]; then
        CURRENT_STATUS="${BASH_REMATCH[1]}"
        
        if [ -n "$CURRENT_NAME" ]; then
            case $CURRENT_STATUS in
                running)
                    echo "✅ $CURRENT_NAME (port ${CURRENT_PORT:-?}) — running"
                    ;;
                stopped)
                    echo "⏹️  $CURRENT_NAME (port ${CURRENT_PORT:-?}) — stopped"
                    ;;
                error)
                    echo "❌ $CURRENT_NAME (port ${CURRENT_PORT:-?}) — ERROR"
                    ;;
                *)
                    echo "❓ $CURRENT_NAME (port ${CURRENT_PORT:-?}) — $CURRENT_STATUS"
                    ;;
            esac
            CURRENT_NAME=""
            CURRENT_PORT=""
            CURRENT_STATUS=""
        fi
    fi
done < "$INSTANCES_FILE"

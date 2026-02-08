#!/bin/bash
# Cron Health Check — Detect stuck crons and optionally restart instances
# Usage: ./cron-health-check.sh [instances-file] [--auto-restart]
#
# Checks each instance's crons against their schedules.
# If a cron has missed 2+ scheduled runs, it's flagged as stuck.
# With --auto-restart, will restart instances with stuck crons.

set -e

SUPERVISOR_WORKSPACE="${SUPERVISOR_WORKSPACE:-$HOME/.openclaw/workspace-supervisor}"
INSTANCES_FILE=${1:-"$SUPERVISOR_WORKSPACE/INSTANCES.yaml"}
AUTO_RESTART=false

for arg in "$@"; do
    if [[ "$arg" == "--auto-restart" ]]; then
        AUTO_RESTART=true
    fi
done

if [ ! -f "$INSTANCES_FILE" ]; then
    echo "No instances file found at $INSTANCES_FILE"
    exit 0
fi

echo "🕐 Cron Health Check — $(date '+%Y-%m-%d %H:%M')"
echo ""

TOTAL_INSTANCES=0
HEALTHY_INSTANCES=0
STUCK_INSTANCES=0

calculate_interval_seconds() {
    local expr="$1"
    local minute=$(echo "$expr" | awk '{print $1}')
    local hour=$(echo "$expr" | awk '{print $2}')

    if [[ "$minute" =~ ^\*/([0-9]+)$ ]]; then
        echo $(( ${BASH_REMATCH[1]} * 60 )); return
    elif [[ "$minute" =~ ^([0-9]+),([0-9]+)$ ]]; then
        echo $(( 30 * 60 )); return
    elif [[ "$minute" =~ ^([0-9]+),([0-9]+),([0-9]+)$ ]]; then
        echo $(( 20 * 60 )); return
    fi

    if [[ "$hour" =~ ^\*/([0-9]+)$ ]]; then
        echo $(( ${BASH_REMATCH[1]} * 3600 )); return
    elif [[ "$hour" == "*" ]] && [[ "$minute" =~ ^[0-9]+$ ]]; then
        echo $(( 60 * 60 )); return
    fi

    echo $(( 24 * 3600 ))
}

check_instance_crons() {
    local profile="$1"
    local name="$2"
    local stuck_count=0
    local checked_count=0
    local now_ms=$(($(date +%s) * 1000))

    local cron_json
    cron_json=$(openclaw --profile "$profile" cron list --json 2>/dev/null) || {
        echo "  ⚠️  Could not query crons"
        return 1
    }

    if ! command -v jq &> /dev/null; then
        echo "  ⚠️  jq not installed, skipping detailed check"
        return 1
    fi

    local jobs
    jobs=$(echo "$cron_json" | jq -c '.jobs[]? // empty' 2>/dev/null) || jobs=""

    while IFS= read -r job; do
        [ -z "$job" ] && continue

        local job_name=$(echo "$job" | jq -r '.name // "unnamed"')
        local enabled=$(echo "$job" | jq -r '.enabled // false')
        local schedule_expr=$(echo "$job" | jq -r '.schedule.expr // ""')
        local schedule_kind=$(echo "$job" | jq -r '.schedule.kind // ""')
        local last_run_ms=$(echo "$job" | jq -r '.state.lastRunAtMs // 0')
        local last_status=$(echo "$job" | jq -r '.state.lastStatus // "unknown"')

        [[ "$enabled" != "true" ]] && continue
        [[ "$schedule_kind" != "cron" ]] && continue

        checked_count=$((checked_count + 1))

        local interval_sec=$(calculate_interval_seconds "$schedule_expr")
        local max_gap_ms=$(( interval_sec * 2 * 1000 ))
        local gap_ms=$((now_ms - last_run_ms))
        local gap_hours=$(( gap_ms / 1000 / 3600 ))
        local gap_mins=$(( (gap_ms / 1000 / 60) % 60 ))

        if [[ $gap_ms -gt $max_gap_ms ]]; then
            echo "  🚨 STUCK: $job_name"
            echo "      Schedule: $schedule_expr (interval: ${interval_sec}s)"
            echo "      Last run: ${gap_hours}h ${gap_mins}m ago"
            echo "      Last status: $last_status"
            stuck_count=$((stuck_count + 1))
        fi
    done <<< "$jobs"

    if [[ $stuck_count -eq 0 ]] && [[ $checked_count -gt 0 ]]; then
        echo "  ✅ All $checked_count crons healthy"
        return 0
    elif [[ $checked_count -eq 0 ]]; then
        echo "  ℹ️  No cron jobs found"
        return 0
    else
        echo "  ❌ $stuck_count/$checked_count crons STUCK"
        return 2
    fi
}

while IFS= read -r line; do
    if [[ $line =~ name:\ *(.+) ]]; then
        CURRENT_NAME="${BASH_REMATCH[1]}"
    fi
    if [[ $line =~ profile:\ *(.+) ]]; then
        CURRENT_PROFILE="${BASH_REMATCH[1]}"
    fi
    if [[ $line =~ port:\ *([0-9]+) ]]; then
        CURRENT_PORT="${BASH_REMATCH[1]}"

        if [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_PORT" ]; then
            TOTAL_INSTANCES=$((TOTAL_INSTANCES + 1))
            PROFILE="${CURRENT_PROFILE:-$CURRENT_NAME}"

            echo "📋 $CURRENT_NAME (profile: $PROFILE, port: $CURRENT_PORT)"

            if ! curl -sf "http://127.0.0.1:${CURRENT_PORT}/health" > /dev/null 2>&1; then
                echo "  ❌ Instance not reachable"
                STUCK_INSTANCES=$((STUCK_INSTANCES + 1))
            else
                check_instance_crons "$PROFILE" "$CURRENT_NAME"
                result=$?

                if [[ $result -eq 2 ]]; then
                    STUCK_INSTANCES=$((STUCK_INSTANCES + 1))

                    if [[ "$AUTO_RESTART" == "true" ]]; then
                        echo "  🔄 Auto-restarting $CURRENT_NAME..."
                        PLIST="$HOME/Library/LaunchAgents/ai.openclaw.${PROFILE}.plist"
                        if [ -f "$PLIST" ]; then
                            launchctl unload "$PLIST" 2>/dev/null
                            sleep 1
                            launchctl load "$PLIST" 2>/dev/null
                            echo "  ✅ Restarted via launchctl"
                        else
                            echo "  ⚠️  No plist found, manual restart needed"
                        fi
                    fi
                else
                    HEALTHY_INSTANCES=$((HEALTHY_INSTANCES + 1))
                fi
            fi

            echo ""
            CURRENT_NAME=""
            CURRENT_PROFILE=""
            CURRENT_PORT=""
        fi
    fi
done < "$INSTANCES_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: $HEALTHY_INSTANCES/$TOTAL_INSTANCES healthy"
if [[ $STUCK_INSTANCES -gt 0 ]]; then
    echo "⚠️  $STUCK_INSTANCES instance(s) with stuck crons"
    if [[ "$AUTO_RESTART" != "true" ]]; then
        echo "   Run with --auto-restart to auto-recover"
    fi
    exit 1
fi
echo "✅ All crons healthy"

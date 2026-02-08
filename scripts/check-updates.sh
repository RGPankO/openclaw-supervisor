#!/bin/bash
# Check for supervisor updates (fetch only, don't apply)
# Usage: ./check-updates.sh

SUPERVISOR_WORKSPACE="${SUPERVISOR_WORKSPACE:-$HOME/.openclaw/workspace-supervisor}"
SUPERVISOR_DIR="$SUPERVISOR_WORKSPACE/openclaw-supervisor"

if [ ! -d "$SUPERVISOR_DIR/.git" ]; then
    echo "Error: Supervisor repo not found at $SUPERVISOR_DIR"
    exit 1
fi

cd "$SUPERVISOR_DIR"

git fetch origin 2>/dev/null

BRANCH=$(git rev-parse --abbrev-ref HEAD)
REMOTE_BRANCH="origin/$BRANCH"

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse $REMOTE_BRANCH 2>/dev/null)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✅ Already up to date"
    exit 0
fi

BEHIND=$(git rev-list --count HEAD..$REMOTE_BRANCH)

echo "📦 Updates available: $BEHIND commit(s)"
echo ""
echo "=== Changes ==="
git log --oneline HEAD..$REMOTE_BRANCH
echo ""
echo "=== Files Changed ==="
git diff --name-only HEAD..$REMOTE_BRANCH
echo ""
echo "=== Full Diff ==="
git diff HEAD..$REMOTE_BRANCH

#!/bin/bash
# Check for supervisor updates (fetch only, don't apply)
# Usage: ./check-updates.sh

SUPERVISOR_DIR="$HOME/.openclaw-supervisor/workspace/supervisor"

if [ ! -d "$SUPERVISOR_DIR/.git" ]; then
    echo "Error: Supervisor repo not found at $SUPERVISOR_DIR"
    exit 1
fi

cd "$SUPERVISOR_DIR"

# Fetch latest
git fetch origin 2>/dev/null

# Get branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
REMOTE_BRANCH="origin/$BRANCH"

# Check if behind
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse $REMOTE_BRANCH 2>/dev/null)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✅ Already up to date"
    exit 0
fi

# Count commits behind
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

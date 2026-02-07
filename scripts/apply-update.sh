#!/bin/bash
# Apply supervisor update (run AFTER check-updates.sh and user confirmation)
# Usage: ./apply-update.sh

SUPERVISOR_DIR="$HOME/.openclaw-supervisor/workspace/supervisor"

if [ ! -d "$SUPERVISOR_DIR/.git" ]; then
    echo "Error: Supervisor repo not found at $SUPERVISOR_DIR"
    echo "Expected a git clone of openclaw-supervisor"
    exit 1
fi

cd "$SUPERVISOR_DIR"

echo "Checking for updates..."

# Fetch latest
git fetch origin

# Check if behind
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✅ Already up to date"
    exit 0
fi

# Show what's new
echo ""
echo "Updates available:"
git log --oneline HEAD..origin/main 2>/dev/null || git log --oneline HEAD..origin/master
echo ""

# Pull updates
echo "Pulling updates..."
git pull origin main 2>/dev/null || git pull origin master

# Re-copy scripts
echo "Updating scripts..."
cp scripts/*.sh "$HOME/.openclaw-supervisor/workspace/scripts/"
chmod +x "$HOME/.openclaw-supervisor/workspace/scripts/"*.sh

# Update role
echo "Updating role..."
cp SUPERVISOR.md "$HOME/.openclaw-supervisor/workspace/ROLES/SUPERVISOR.md"

echo ""
echo "✅ Updated successfully!"
echo "Restart gateway to apply any config changes."

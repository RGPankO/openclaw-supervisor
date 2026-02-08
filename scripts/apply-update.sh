#!/bin/bash
# Apply supervisor update (run AFTER check-updates.sh and user confirmation)
# Usage: ./apply-update.sh

SUPERVISOR_WORKSPACE="${SUPERVISOR_WORKSPACE:-$HOME/.openclaw/workspace-supervisor}"
SUPERVISOR_DIR="$SUPERVISOR_WORKSPACE/openclaw-supervisor"

if [ ! -d "$SUPERVISOR_DIR/.git" ]; then
    echo "Error: Supervisor repo not found at $SUPERVISOR_DIR"
    exit 1
fi

cd "$SUPERVISOR_DIR"

echo "Pulling updates..."
git pull origin main 2>/dev/null || git pull origin master

# Re-copy scripts
echo "Updating scripts..."
cp scripts/*.sh "$SUPERVISOR_WORKSPACE/scripts/"
chmod +x "$SUPERVISOR_WORKSPACE/scripts/"*.sh

# Update role
echo "Updating role..."
cp SUPERVISOR.md "$SUPERVISOR_WORKSPACE/ROLES/SUPERVISOR.md"

echo ""
echo "✅ Updated successfully!"

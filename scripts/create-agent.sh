#!/bin/bash
# Create a new OpenClaw agent from template
# Usage: ./create-agent.sh <name> <port> <channel> <channel_token>
#
# Examples:
#   ./create-agent.sh researcher 18801 telegram 1234567890:ABCdef...
#   ./create-agent.sh coder 18802 discord MTIzNDU2Nzg5...

set -e

NAME=$1
PORT=$2
CHANNEL=$3
CHANNEL_TOKEN=$4
SUPERVISOR_WORKSPACE="$HOME/.openclaw-supervisor/workspace"
TEMPLATE="$SUPERVISOR_WORKSPACE/CONFIG-TEMPLATE.yaml"

# Validate inputs
if [ -z "$NAME" ] || [ -z "$PORT" ] || [ -z "$CHANNEL" ] || [ -z "$CHANNEL_TOKEN" ]; then
    echo "Usage: $0 <name> <port> <channel> <channel_token>"
    echo ""
    echo "Channels: telegram, discord, slack, signal"
    echo ""
    echo "Examples:"
    echo "  $0 researcher 18801 telegram 1234567890:ABCdefGHI..."
    echo "  $0 coder 18802 discord MTIzNDU2Nzg5MDEyMzQ1..."
    exit 1
fi

# Validate channel
case $CHANNEL in
    telegram|discord|slack|signal)
        ;;
    *)
        echo "Error: Unknown channel '$CHANNEL'"
        echo "Supported: telegram, discord, slack, signal"
        exit 1
        ;;
esac

# Check if profile already exists
if [ -d "$HOME/.openclaw-$NAME" ]; then
    echo "Error: Profile '$NAME' already exists at ~/.openclaw-$NAME"
    exit 1
fi

# Check if port is in use
if lsof -i :$PORT > /dev/null 2>&1; then
    echo "Error: Port $PORT is already in use"
    exit 1
fi

# Check if template exists
if [ ! -f "$TEMPLATE" ]; then
    echo "Error: CONFIG-TEMPLATE.yaml not found"
    echo "Create it from CONFIG-TEMPLATE.example.yaml first:"
    echo "  cp supervisor/CONFIG-TEMPLATE.example.yaml CONFIG-TEMPLATE.yaml"
    echo "  # Edit with your API keys"
    exit 1
fi

echo "Creating agent: $NAME"
echo "  Port: $PORT"
echo "  Channel: $CHANNEL"
echo "  Profile: ~/.openclaw-$NAME"
echo ""

# Create directory structure
AGENT_HOME="$HOME/.openclaw-$NAME"
mkdir -p "$AGENT_HOME/workspace"

# Generate random gateway auth token
GATEWAY_TOKEN=$(openssl rand -hex 24)

# Create config from template
echo "→ Creating config from template..."

# Use Python to parse YAML template and create JSON config
python3 << EOF
import yaml
import json
import sys

# Read template
with open("$TEMPLATE", 'r') as f:
    config = yaml.safe_load(f)

# Inject gateway values
config['gateway']['port'] = $PORT
config['gateway']['auth']['token'] = "$GATEWAY_TOKEN"

# Set workspace
if 'agents' not in config:
    config['agents'] = {}
if 'defaults' not in config['agents']:
    config['agents']['defaults'] = {}
config['agents']['defaults']['workspace'] = "$AGENT_HOME/workspace"

# Configure channel
channel = "$CHANNEL"
token = "$CHANNEL_TOKEN"

if 'channels' not in config:
    config['channels'] = {}

# Disable all channels first
for ch in ['telegram', 'discord', 'slack', 'signal']:
    if ch in config.get('channels', {}):
        config['channels'][ch]['enabled'] = False

# Enable and configure the selected channel
if channel == 'telegram':
    config['channels']['telegram'] = {
        'enabled': True,
        'botToken': token,
        'dmPolicy': 'pairing',
        'groupPolicy': 'allowlist',
        'streamMode': 'partial'
    }
elif channel == 'discord':
    config['channels']['discord'] = {
        'enabled': True,
        'botToken': token
    }
elif channel == 'slack':
    config['channels']['slack'] = {
        'enabled': True,
        'botToken': token
    }
elif channel == 'signal':
    config['channels']['signal'] = {
        'enabled': True,
        'phoneNumber': token
    }

# Add meta
config['meta'] = {
    'createdBy': 'openclaw-supervisor',
    'createdAt': '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
    'agentName': '$NAME',
    'channel': '$CHANNEL'
}

# Write JSON config
with open("$AGENT_HOME/openclaw.json", 'w') as f:
    json.dump(config, f, indent=2)

print("Config created successfully")
EOF

if [ $? -ne 0 ]; then
    echo "Error: Failed to create config"
    rm -rf "$AGENT_HOME"
    exit 1
fi

echo "→ Profile created at $AGENT_HOME"
echo ""

# Auto-start the gateway
echo "→ Starting gateway..."
openclaw --profile "$NAME" gateway start &
sleep 2

echo ""
echo "✅ Agent '$NAME' is live!"
echo ""
echo "Channel: $CHANNEL"
echo "Port: $PORT"
echo ""
echo "Message the agent via $CHANNEL to configure it."

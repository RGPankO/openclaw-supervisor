# OpenClaw Supervisor

A supervisor agent that manages multiple OpenClaw instances on a single machine.

## What It Does

- **Health monitoring** — Checks if agents are running every 5 minutes
- **Auto-restart** — Restarts crashed agents
- **Instance management** — Spin up/down agents via chat
- **Status dashboard** — Quick view of all agents
- **Self-updating** — Checks for updates daily

## Architecture

```
Mac Mini (or any machine)
│
├── ~/.openclaw-supervisor/     # Port 18800 — The boss
│   └── workspace/
│       ├── framework/          # OpenClaw Framework (dependency)
│       ├── supervisor/         # This repo
│       └── INSTANCES.yaml      # Tracks all agents
│
├── ~/.openclaw-agent1/         # Port 18801 — Worker
├── ~/.openclaw-agent2/         # Port 18802 — Worker
└── ...
```

## Prerequisites

1. OpenClaw installed (`npm install -g openclaw`)
2. **OpenClaw Framework installed first** — This supervisor depends on the framework

## Installation

### Step 1: Set Up Supervisor Profile

```bash
openclaw --profile supervisor setup
```

Follow the wizard. Configure your Telegram bot.

### Step 2: Install Framework

Start the gateway and tell your supervisor:

> "Install the OpenClaw Framework from https://github.com/RGPankO/openclaw-framework"

### Step 3: Install Supervisor

Once framework is wired in, tell your supervisor:

> "Install the Supervisor from https://github.com/RGPankO/openclaw-supervisor"

The agent will:
1. Clone this repo to `workspace/supervisor/`
2. Ask you to create CONFIG-TEMPLATE.yaml with your API keys
3. Copy SUPERVISOR.md to ROLES/
4. Copy scripts to workspace
5. Create INSTANCES.yaml
6. Set up Health Check cron (every 5 min)
7. Set up Auto-Update cron (daily)

### Step 4: Create Config Template

When prompted, create your config template:

```bash
cp supervisor/CONFIG-TEMPLATE.example.yaml CONFIG-TEMPLATE.yaml
# Edit CONFIG-TEMPLATE.yaml with your Anthropic API key
```

This template is used when creating new agents.

## Usage

Once installed, talk to your supervisor:

| Say | Does |
|-----|------|
| "Create agent researcher on port 18801 with telegram XXX" | Spins up new agent |
| "Status" | Shows all agents |
| "Stop researcher" | Stops an agent |
| "Start researcher" | Starts an agent |
| "Restart researcher" | Restarts an agent |
| "Logs for researcher" | Shows recent logs |
| "Check for updates" | Checks for supervisor updates |

## Creating New Agents

Each agent needs:
- **Unique name** (e.g., "researcher")
- **Unique port** (e.g., 18801)
- **Communication channel** (telegram, discord, slack, signal)
- **Channel credentials** (bot token, phone number, etc.)

API keys are shared from your CONFIG-TEMPLATE.yaml.

**Examples:**
```
"Create agent researcher on port 18801 with telegram 123456:ABC..."
"Create agent coder on port 18802 with discord MTIzNDU2..."
```

After creating, communicate with the agent via its configured channel.

## Files

| File | Purpose |
|------|---------|
| `SUPERVISOR.md` | Role definition — the supervisor's brain |
| `INSTALL.md` | Wiring instructions (for agent to read) |
| `CONFIG-TEMPLATE.example.yaml` | Template for agent configs |
| `INSTANCES.example.yaml` | Template for tracking agents |
| `TASKS/AUTO-UPDATE.md` | Update check instructions |
| `scripts/` | Shell scripts for operations |

## Dependencies

- **OpenClaw Framework** — Must be installed first
- Uses framework's ROLES/, TASKS/, context management

## License

MIT

# OpenClaw Supervisor

A supervisor agent that manages multiple OpenClaw instances on a single machine.

## What It Does

- **Health monitoring** — Checks if agents are running (hourly)
- **Auto-restart** — Restarts crashed agents via launchctl
- **Instance management** — Start/stop/restart agents via chat
- **Status dashboard** — Quick view of all agents
- **Cron health** — Detects stuck cron jobs across instances
- **Self-updating** — Checks for updates daily

## Architecture

```
Mac Mini (or any machine)
│
├── ~/.openclaw-supervisor/          # Supervisor profile (config, logs, cron)
│
├── ~/.openclaw/workspace-supervisor/  # Supervisor workspace
│   ├── openclaw-framework/          # Framework (dependency)
│   ├── openclaw-supervisor/         # This repo
│   ├── INSTANCES.yaml               # Tracks all agents
│   ├── ROLES/SUPERVISOR.md          # Role definition
│   ├── scripts/                     # Operational scripts
│   └── ...
│
├── ~/.openclaw-agent1/              # Worker (created manually)
├── ~/.openclaw-agent2/              # Worker (created manually)
└── ...
```

**Note:** The workspace path is configurable via `SUPERVISOR_WORKSPACE` env var.
Default: `~/.openclaw/workspace-supervisor/`

## Prerequisites

- OpenClaw installed (`npm install -g openclaw`)
- OpenClaw Framework installed first — This supervisor depends on the framework

## Installation

### Step 1: Set Up Supervisor Profile

```bash
openclaw --profile supervisor setup
```

Follow the wizard. Configure your channel (Telegram, Discord, etc.).

### Step 2: Install Framework

Start the gateway and tell your supervisor:

> "Install the OpenClaw Framework from https://github.com/RGPankO/openclaw-framework"

### Step 3: Install Supervisor

Once framework is wired in, tell your supervisor:

> "Install the Supervisor from https://github.com/RGPankO/openclaw-supervisor"

The agent will:
- Clone this repo to workspace
- Copy SUPERVISOR.md to ROLES/
- Copy scripts to workspace
- Create INSTANCES.yaml
- Set up crons (Health Check, Auto-Update, Cron Health Check)

## Creating New Agents

Agent creation is done **manually** by the user:

```bash
openclaw --profile <name> configure    # Interactive setup wizard
openclaw --profile <name> gateway install  # Install as launchd service
openclaw --profile <name> gateway start    # Start the service
```

Then tell the supervisor to add it to INSTANCES.yaml.

Each agent needs:
- Unique name and port
- Its own channel credentials (bot token, etc.)

## Usage

Once installed, talk to your supervisor:

| Say | Does |
|-----|------|
| "Status" | Shows all agents |
| "Stop X" | Stops an agent |
| "Start X" | Starts an agent |
| "Restart X" | Restarts an agent |
| "Health check" | Check all agents now |
| "Cron check" | Detect stuck crons |
| "Logs for X" | Shows recent logs |
| "Check for updates" | Check for supervisor updates |

## Technical Notes

- **Service management uses `launchctl`** directly (not `openclaw gateway stop/start` which can be unreliable with `--profile`)
- **Health checks use `curl`** against `http://127.0.0.1:<port>/health` (not `openclaw gateway health` which may probe the wrong port)
- **Scripts use `SUPERVISOR_WORKSPACE` env var** — set it if your workspace isn't at the default path

## Files

| File | Purpose |
|------|---------|
| SUPERVISOR.md | Role definition — the supervisor's brain |
| INSTALL.md | Wiring instructions (for agent to read) |
| INSTANCES.example.yaml | Template for tracking agents |
| scripts/ | Shell scripts for operations |
| TASKS/ | Task definitions for crons |

## Dependencies

- **OpenClaw Framework** — Must be installed first
- **jq** — Required for cron health checks
- **curl** — Required for health checks

## License

MIT

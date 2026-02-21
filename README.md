# OpenClaw Supervisor

A supervisor agent that manages multiple OpenClaw instances on a single machine.

## What It Does

- **Monitors instances** via native OpenClaw heartbeat
- **Auto-restarts** crashed instances via launchctl
- **Alerts you** when something needs attention
- **Tracks instances** in a simple YAML file

## How It Works

No custom crons. No shell scripts. The supervisor uses OpenClaw's built-in **heartbeat** as its single operational loop.

Every heartbeat cycle, the supervisor:
1. Reads `INSTANCES.yaml` for managed instances
2. Checks each one (launchctl status + port health)
3. Restarts anything that's down
4. Alerts you if it intervened or couldn't fix something
5. Stays silent if everything's fine

## Files

| File | Purpose |
|------|---------|
| `SUPERVISOR.md` | Role definition — what the supervisor can do |
| `HEARTBEAT.md` | The operational loop — replaces all crons |
| `INSTANCES.example.yaml` | Template for tracking instances |
| `INSTALL.md` | Setup instructions (for the agent to read) |

## Setup

### 1. Create a supervisor profile

```bash
openclaw --profile supervisor setup
```

### 2. Install

Start the gateway and tell your supervisor:

> "Install the Supervisor from https://github.com/RGPankO/openclaw-supervisor"

The agent will read `INSTALL.md` and wire everything in.

### 3. Configure heartbeat

In your supervisor's config (`~/.openclaw-supervisor/openclaw.json`), set the heartbeat interval:

```json
{
  "agents": {
    "defaults": {
      "heartbeat": {
        "every": "2h",
        "target": "last"
      }
    }
  }
}
```

Restart the gateway to apply.

### 4. Add your instances

Edit `INSTANCES.yaml` in the workspace:

```yaml
instances:
  - name: my-assistant
    profile: my-assistant
    port: 18801
    managed: true
    notes: "Day-to-day assistant"
```

## Usage

Talk to your supervisor:

| Say | Does |
|-----|------|
| "Status" | Shows all instances |
| "Stop X" | Stops an instance |
| "Start X" | Starts an instance |
| "Restart X" | Restarts an instance |
| "Health check" | Check all instances now |
| "Add X" | Add to INSTANCES.yaml |

## Design Decisions

- **Heartbeat over crons** — One native loop instead of isolated cron sessions that lack context and need separate model configs
- **launchctl over CLI** — `openclaw --profile` has routing bugs; launchctl is direct and reliable
- **curl over CLI health** — `openclaw gateway health` may probe the wrong port; curl is explicit
- **No framework dependency** — Supervisor is self-contained; doesn't need the general-purpose framework
- **Managed flag** — Track instances you know about but aren't ready to monitor yet

## License

MIT

# Installation Instructions

*For the OpenClaw agent to read and execute.*

## Step 1: Clone Repository

```bash
cd <workspace>
git clone https://github.com/RGPankO/openclaw-supervisor openclaw-supervisor
```

## Step 2: Copy Role

```bash
mkdir -p ROLES
cp openclaw-supervisor/SUPERVISOR.md ROLES/SUPERVISOR.md
```

## Step 3: Copy Heartbeat

```bash
cp openclaw-supervisor/HEARTBEAT.md HEARTBEAT.md
```

## Step 4: Create Instance List

```bash
cp openclaw-supervisor/INSTANCES.example.yaml INSTANCES.yaml
```

Edit `INSTANCES.yaml` to list the actual instances on this machine.

## Step 5: Update AGENTS.md

Add to the session startup sequence:

```markdown
### Supervisor Role
- If you haven't read `ROLES/SUPERVISOR.md` this session, read it now
- Read `INSTANCES.yaml` — current managed instances
```

## Step 6: Configure Heartbeat

Set heartbeat interval in your OpenClaw config (`~/.openclaw-<profile>/openclaw.json`):

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

Then restart the gateway so it picks up the config.

## Step 7: Confirm

```
✅ Supervisor installed!

Monitoring via heartbeat (no custom crons needed).
Add instances to INSTANCES.yaml as you create them.
```

## Notes

- No framework dependency required
- No custom crons — heartbeat is the single operational loop
- Service management uses `launchctl` directly (avoids `openclaw --profile` routing bugs)
- Health checks use `curl` against instance ports

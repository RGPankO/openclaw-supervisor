# Installation Instructions

*For the OpenClaw agent to read and execute.*

---

## Prerequisites Check

1. **Framework installed?** Check if `openclaw-framework/FRAMEWORK.md` exists in workspace
   - If NOT: Tell user "Please install the OpenClaw Framework first"
   - If YES: Continue

2. **ROLES/ and TASKS/ directories exist?**
   - If NOT: `mkdir -p ROLES TASKS`

---

## Step 1: Clone Repository

```bash
cd <workspace>
git clone https://github.com/RGPankO/openclaw-supervisor openclaw-supervisor
```

---

## Step 2: Copy Role

```bash
cp openclaw-supervisor/SUPERVISOR.md ROLES/SUPERVISOR.md
```

---

## Step 3: Copy Scripts

```bash
mkdir -p scripts
cp openclaw-supervisor/scripts/*.sh scripts/
chmod +x scripts/*.sh
```

---

## Step 4: Copy Task Definitions

```bash
cp -r openclaw-supervisor/TASKS/* TASKS/
```

---

## Step 5: Create INSTANCES.yaml

```bash
cat > INSTANCES.yaml << 'EOF'
# Managed OpenClaw Instances
# Updated by supervisor agent

instances: []
EOF
```

---

## Step 6: Update AGENTS.md

Add supervisor role to the session startup sequence:

```markdown
### Supervisor Role
- Read `ROLES/SUPERVISOR.md` — my capabilities and commands
- Read `INSTANCES.yaml` — current managed agents
```

---

## Step 7: Create Crons

### Health Check (hourly, disabled until instances exist)

```
cron add: "Health Check"
schedule: "0 * * * *" (user's timezone)
model: worker_model
enabled: false
message: "Read ROLES/SUPERVISOR.md. Run ./scripts/health-check.sh. If any agent is down, attempt restart and alert user. If all healthy, reply HEARTBEAT_OK."
```

### Supervisor Auto-Update (daily)

```
cron add: "Supervisor Auto-Update"
schedule: "30 4 * * *" (user's timezone, offset from framework auto-update)
model: worker_model
message: "Read TASKS/README.md. Then read TASKS/AUTO-UPDATE/TASK.md and follow instructions."
```

### Cron Health Check (every 4 hours, disabled until instances exist)

```
cron add: "Cron Health Check"
schedule: "30 */4 * * *" (user's timezone)
model: worker_model
enabled: false
message: "Read ROLES/SUPERVISOR.md. Run ./scripts/cron-health-check.sh. If any stuck, restart and report. If all healthy, reply HEARTBEAT_OK."
```

---

## Step 8: Confirm

```
✅ Supervisor installed!

**What I can do:**
- Monitor agent health (hourly)
- Start/stop/restart agents
- Detect stuck crons
- Check for updates (daily)

**Agent creation is manual:**
  openclaw --profile <name> configure
  openclaw --profile <name> gateway install
  openclaw --profile <name> gateway start

Then tell me to add it to INSTANCES.yaml.
```

---

## Notes

- Scripts use `SUPERVISOR_WORKSPACE` env var (defaults to `~/.openclaw/workspace-supervisor/`)
- Health checks use `curl` (not `openclaw gateway health`)
- Service management uses `launchctl` (not `openclaw gateway stop/start`)
- These choices avoid `--profile` routing bugs in the OpenClaw CLI

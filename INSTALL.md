# Installation Instructions

*For the OpenClaw agent to read and execute.*

---

## Prerequisites Check

Before proceeding, verify:

1. **Framework installed?** Check if `workspace/framework/FRAMEWORK.md` exists
   - If NOT: Tell user "Please install the OpenClaw Framework first: https://github.com/RGPankO/openclaw-framework"
   - If YES: Continue

2. **ROLES/ directory exists?** 
   - If NOT: `mkdir -p ~/.openclaw-supervisor/workspace/ROLES`

3. **TASKS/ directory exists?**
   - If NOT: `mkdir -p ~/.openclaw-supervisor/workspace/TASKS`

---

## Step 1: Clone Repository

```bash
cd ~/.openclaw-supervisor/workspace
git clone https://github.com/RGPankO/openclaw-supervisor supervisor
```

---

## Step 2: Config Template Setup

**Tell user:**

> "Before I can create agents, you need to set up CONFIG-TEMPLATE.yaml with your API keys.
> 
> Run:
> ```
> cp supervisor/CONFIG-TEMPLATE.example.yaml CONFIG-TEMPLATE.yaml
> ```
> 
> Then edit CONFIG-TEMPLATE.yaml and add your Anthropic API key.
> 
> Let me know when done."

**Wait for user confirmation before continuing.**

---

## Step 3: Copy Role

```bash
cp ~/.openclaw-supervisor/workspace/supervisor/SUPERVISOR.md \
   ~/.openclaw-supervisor/workspace/ROLES/SUPERVISOR.md
```

---

## Step 4: Copy Scripts

```bash
mkdir -p ~/.openclaw-supervisor/workspace/scripts
cp ~/.openclaw-supervisor/workspace/supervisor/scripts/*.sh \
   ~/.openclaw-supervisor/workspace/scripts/
chmod +x ~/.openclaw-supervisor/workspace/scripts/*.sh
```

---

## Step 5: Copy Task Definitions

```bash
# Copy TASKS directory structure (README + task directories)
cp -r ~/.openclaw-supervisor/workspace/supervisor/TASKS/* \
   ~/.openclaw-supervisor/workspace/TASKS/
```

---

## Step 6: Create INSTANCES.yaml

```bash
cat > ~/.openclaw-supervisor/workspace/INSTANCES.yaml << 'EOF'
# Managed OpenClaw Instances
# Updated by supervisor agent

instances: []
EOF
```

---

## Step 7: Update AGENTS.md

Add this section to the user's AGENTS.md under "Every Session":

```markdown
## Every Session

Before doing anything else:
1. Read `MISSION.md` — our purpose
2. Read `ROLES/SUPERVISOR.md` — My role and capabilities
3. Read `INSTANCES.yaml` — Current managed agents
4. Read `framework/FRAMEWORK.md` — Framework rules

## Supervisor Role

I am a supervisor agent managing multiple OpenClaw instances.

**Commands I handle:**
- Create/start/stop/restart agents
- Health checks (via cron)
- Cron health monitoring (detect stuck crons)
- Status reports
```

---

## Step 8: Create Crons

### Health Check (hourly)

```
cron action=add job={
  "name": "Health Check",
  "schedule": {"kind": "cron", "expr": "0 * * * *", "tz": "UTC"},
  "sessionTarget": "isolated",
  "enabled": true,
  "payload": {
    "kind": "agentTurn",
    "message": "Read ROLES/SUPERVISOR.md. Run health check on all instances in INSTANCES.yaml. If any agent is down, attempt restart and alert user. If all healthy, reply HEARTBEAT_OK silently (no Telegram message)."
  },
  "delivery": {"mode": "announce", "bestEffort": true}
}
```

### Auto-Update (daily at 4am)

```
cron action=add job={
  "name": "Supervisor Auto-Update",
  "schedule": {"kind": "cron", "expr": "0 4 * * *", "tz": "UTC"},
  "sessionTarget": "isolated",
  "enabled": true,
  "payload": {
    "kind": "agentTurn",
    "message": "Read TASKS/README.md for execution rules. Then read TASKS/AUTO-UPDATE/TASK.md and follow instructions. If no updates, reply HEARTBEAT_OK."
  },
  "delivery": {"mode": "announce", "bestEffort": true}
}
```

### Cron Health Check (every 4 hours)

```
cron action=add job={
  "name": "Cron Health Check",
  "schedule": {"kind": "cron", "expr": "30 */4 * * *", "tz": "UTC"},
  "sessionTarget": "isolated",
  "enabled": true,
  "payload": {
    "kind": "agentTurn",
    "message": "Read ROLES/SUPERVISOR.md. Run ./scripts/cron-health-check.sh to detect stuck crons. If any found, restart those instances. Report results."
  },
  "delivery": {"mode": "announce", "bestEffort": true}
}
```

---

## Step 9: Confirm to User

Reply:

> "✅ Supervisor installed!
> 
> **What I can do:**
> - Create new OpenClaw agents
> - Monitor agent health (every 5 min)
> - Start/stop/restart agents
> - Check for updates (daily)
> 
> **Supported channels:** telegram, discord, slack, signal
> 
> **Try it:** 'Create agent called test on port 18801 with telegram YOUR_BOT_TOKEN'
> 
> **Note:** Each agent needs its own channel credentials (bot token, etc.)."

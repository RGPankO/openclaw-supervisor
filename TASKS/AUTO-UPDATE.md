# Task: Supervisor Auto-Update

## Model

**Use:** `worker_model` — Simple git operations

## Schedule

Daily at 04:00 UTC (or user-configured)

## Purpose

Check for updates to the supervisor repo and notify user.

## Instructions

### 1. Fetch Remote (No Pull)

```bash
cd ~/.openclaw-supervisor/workspace/supervisor
git fetch origin main
```

### 2. Check for Updates

```bash
git log HEAD..origin/main --oneline
```

If no new commits → reply HEARTBEAT_OK and exit.

### 3. Analyze Changes

```bash
# Commits
git log HEAD..origin/main --pretty=format:"%h %s"

# Files changed
git diff HEAD..origin/main --stat

# Check for breaking changes in key files
git diff HEAD..origin/main -- CONFIG-TEMPLATE.example.yaml
git diff HEAD..origin/main -- INSTANCES.example.yaml
git diff HEAD..origin/main -- SUPERVISOR.md
```

### 4. Assess Impact

- **Low:** Script fixes, documentation
- **Medium:** New features, new commands
- **High:** Config format changes, breaking changes

### 5. Report to User

```
📦 Supervisor Update Available

**Changes:**
- [commit list]

**Files:**
- [file list]

**Impact:** [Low/Medium/High]
- [any breaking changes or migrations needed]

Reply "update supervisor" to apply.
```

### 6. Wait for Confirmation

Do NOT auto-apply. Wait for user to confirm.

### 7. If User Confirms

Run the update:
```bash
cd ~/.openclaw-supervisor/workspace/supervisor
git pull origin main

# Re-copy updated files
cp scripts/*.sh ../scripts/
chmod +x ../scripts/*.sh
cp SUPERVISOR.md ../ROLES/SUPERVISOR.md
```

Check if CONFIG-TEMPLATE format changed — warn user if they need to update their copy.

### 8. Log

```
## Supervisor Update [HH:MM]
- Status: [No updates / Available / Applied]
- Version: [commit hash]
```

## Error Handling

If git fails → notify user, don't retry.

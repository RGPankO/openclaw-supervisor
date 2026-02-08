# Task Execution Rules

**Read this before executing any task.**

## Directory Structure

Every task has:
```
TASKS/[NAME]/
├── TASK.md      # What to do (specific instructions)
├── HANDOFF.md   # Current state (read first, update at end)
└── runs/        # Session history (append-only logs)
```

## Execution Order

The cron tells you: "Read README.md, then read TASK.md"

After reading TASK.md, before doing the work:

1. **Read `HANDOFF.md`** — Understand current state, what happened last time, advice from previous run
2. **Optionally scan `runs/`** — If you need more historical context, check recent session logs
3. **If task specifies a Role** — Read the role file mentioned in TASK.md

Then execute the task instructions.

## After Completing

1. **Update `HANDOFF.md`** with:
   - What you did this session
   - Current state
   - Advice for next run
   - Remove stale/outdated information — keep it fresh

2. **Write session log** to `runs/YYYY-MM-DD-HHMM.md`:
   - Detailed log of actions taken
   - Commands run, files changed
   - Decisions made and why
   - Same as your summary + technical details

3. **Send summary** if delivery is configured

## HANDOFF.md Format

```markdown
# Handoff

## Current State
[Where things stand right now]

## Last Session
[What was just done, when]

## Next Steps
[What should happen next]

## Watch Out For
[Gotchas, blockers, things to remember]

## Notes
[Anything else useful]
```

## Session Log Format (runs/)

Filename: `YYYY-MM-DD-HHMM.md`

```markdown
# [Task Name] — YYYY-MM-DD HH:MM

## What I Did
[Summary of work]

## Details
[Commands, files changed, technical specifics]

## Decisions
[Any choices made and why]

## For Next Run
[Anything the next session should know]
```

## Important Rules

1. **HANDOFF.md is dynamic** — Update every run, remove stale info
2. **runs/ is append-only** — Never delete or modify past logs
3. **Be explicit** — Task agents may use simpler models; leave clear context
4. **Don't exceed scope** — Do the task, don't start unrelated work
5. **Always log** — Every execution should be recorded

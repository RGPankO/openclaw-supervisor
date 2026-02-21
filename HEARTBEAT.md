# HEARTBEAT.md

If you haven't loaded your role this session, read `ROLES/SUPERVISOR.md` first.

## Operational Loop

You just woke up from a heartbeat. Run through this checklist:

### 1. Check Managed Instances

Read `INSTANCES.yaml`. For each instance where `managed: true`:

```bash
# Check launchctl status
launchctl list | grep ai.openclaw.<profile>
# Look at exit code: 0 = running, 1 or other = problem

# Check port is responding
curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:<port>/health
# 200 = healthy
```

### 2. Act on Problems

If an instance is down or unhealthy:

1. **Try restart:**
   ```bash
   launchctl bootout gui/$(id -u)/ai.openclaw.<profile>
   sleep 2
   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/ai.openclaw.<profile>.plist
   ```

2. **If port blocked by orphan process:**
   ```bash
   /usr/sbin/lsof -i :<port> -t   # find PID
   kill <pid>                       # kill orphan
   # then restart service
   ```

3. **Verify restart worked** — check launchctl + port again.

4. **Alert user** via message tool with what happened and outcome.

### 3. Decide

- **All managed instances healthy** → reply `HEARTBEAT_OK`
- **Intervened or found issues** → reply with brief alert summary (no `HEARTBEAT_OK`)

# Step 2: Verify Deployment (Optional)

Verify that the application has been successfully deployed and all services are running correctly.

## Objective

Confirm that:
- Docker containers are running and healthy
- Bonita server is accessible
- Processes are deployed and enabled
- All artifacts are available

## Prerequisites

- Step 1 completed successfully (or `--skip-build` flag used)
- Docker services are running

## Quick Verification Script

A ready-to-use verification script is available:

```bash
.claude/skills/bonita-deploy-local/verify.sh
```

This script automatically performs all verification steps below and provides a summary report.

## Instructions

### 1. Check Docker Container Status

Verify all containers are running:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Expected Output:**
```
NAMES               STATUS                   PORTS
bonita              Up (healthy)             0.0.0.0:8080->8080/tcp
postgres            Up                       0.0.0.0:5432->5432/tcp
mail                Up                       0.0.0.0:1025->1025/tcp, 0.0.0.0:8025->8025/tcp
```

**Status Indicators:**
- `Up (healthy)` - Container is running and passed health checks
- `Up` - Container is running
- `Exited` or missing - Container failed to start

### 2. Test Bonita Server Connectivity

Check if Bonita server is responding:

```bash
curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/bonita/loginservice"
```

**Expected Response:**
- `401` - Server is running (authentication required - this is correct!)
- `200` - Server is running
- `000` or timeout - Server is not accessible

**Test Login:**
```bash
curl -c cookies.txt \
  -d 'username=install&password=install&redirect=false' \
  http://localhost:8080/bonita/loginservice
```

**Expected:** Sets cookies (session established)

### 3. List Deployed Processes

Check what processes are deployed using REST API:

```bash
# Login
curl -s -c cookies.txt \
  -d 'username=install&password=install&redirect=false' \
  http://localhost:8080/bonita/loginservice

# Get API token
API_TOKEN=$(grep X-Bonita-API-Token cookies.txt | awk '{print $7}')

# List processes
curl -s -b cookies.txt \
  -H "X-Bonita-API-Token: $API_TOKEN" \
  http://localhost:8080/bonita/API/bpm/process | jq .
```

**Expected Output:**
```json
[
  {
    "id": "8234567890123456789",
    "name": "ValidationRecrutement",
    "version": "1.6",
    "activationState": "ENABLED",
    "deploymentDate": "2026-01-27 ..."
  },
  {
    "id": "9345678901234567890",
    "name": "ValidationRecrutementZ",
    "version": "1.4",
    "activationState": "ENABLED",
    "deploymentDate": "2026-01-27 ..."
  }
]
```

### 4. Check Artifact Archive

Verify the build artifact exists:

```bash
ls -lh app/target/poc-cnaf-rh2026-*.zip
```

**Expected:**
```
-rw-r--r--  1 user  staff   9.8M Jan 27 22:54 app/target/poc-cnaf-rh2026-1.0.0-presales.zip
```

### 5. Check Docker Logs

Review recent container logs for errors:

```bash
# Bonita logs (last 50 lines)
docker logs bonita --tail 50

# Check for errors
docker logs bonita 2>&1 | grep -i error | tail -20

# PostgreSQL logs
docker logs postgres --tail 20
```

**Look for:**
- ✓ `Server started in XXXXXms` - Bonita started successfully
- ✓ `Organization imported successfully` - Organization deployed
- ✓ `Process deployed` - Processes deployed
- ✗ `ERROR` lines - Investigate errors
- ✗ `Exception` - Investigate exceptions

### 6. Access Bonita Portal

Open Bonita Portal in browser:

```bash
open http://localhost:8080/bonita
```

**Manual Verification:**
1. Login with `install` / `install`
2. Navigate to **BPM → Processes**
3. Verify processes are listed and **Enabled**
4. Navigate to **Organization → Users**
5. Verify organization structure is deployed

### 7. Generate Deployment Summary

Display comprehensive deployment status:

```
Deployment Verification
=======================

Docker Containers:
✓ bonita: Running and healthy
✓ postgres: Running
✓ mail: Running

Bonita Server:
✓ URL: http://localhost:8080/bonita
✓ Status: Responding (HTTP 401)
✓ Authentication: Working

Deployed Artifacts:
✓ Archive: poc-cnaf-rh2026-1.0.0-presales.zip (9.8 MB)
✓ Docker Image: poc-cnaf-rh2026:1.0.0

Deployed Processes:
✓ ValidationRecrutement v1.6 (ENABLED)
✓ ValidationRecrutementZ v1.4 (ENABLED)

Organization:
✓ CNAF_organization.xml deployed

Profiles:
✓ default_profile.xml deployed
✓ CNAF_profiles.xml deployed

BDM:
✓ Business Data Model deployed

Access URLs:
- Bonita Portal: http://localhost:8080/bonita
- Mail UI: http://localhost:8025
- Credentials: install / install

Status: ALL CHECKS PASSED ✓
```

## Verification Checklist

Use this checklist to confirm deployment:

- [ ] Docker containers are running
- [ ] Bonita server responds to HTTP requests
- [ ] Can login to Bonita Portal
- [ ] Processes are visible in Process list
- [ ] Processes are in ENABLED state
- [ ] Organization structure is loaded
- [ ] BDM is deployed (check Data → Business Data Model)
- [ ] Profiles are available
- [ ] No critical errors in logs

## Common Issues

### Container Not Running

**Issue:** Container shows `Exited` status

**Solution:**
1. Check logs: `docker logs <container-name>`
2. Look for error messages
3. Restart container: `docker compose up -d <container-name>`
4. If persistent, rebuild: `cd infrastructure && ./build.sh`

### Bonita Server Not Responding

**Issue:** `curl` returns `000` or times out

**Possible Causes:**
- Container not healthy yet (still starting up)
- Port conflict
- Container crashed

**Solution:**
1. Wait 30 seconds for startup: `docker logs bonita -f`
2. Check container status: `docker ps`
3. Verify port 8080 is not used: `lsof -i :8080`
4. Restart container if needed

### Processes Not Enabled

**Issue:** Processes show `DISABLED` state

**Solution:**
Processes should be auto-enabled. If not:
```bash
# Manually enable using REST API
tools/enable-processes/enable-processes.sh
```

### Authentication Fails

**Issue:** Cannot login with `install` / `install`

**Possible Causes:**
- Organization not deployed
- Database issue
- User not created

**Solution:**
1. Check organization deployment in logs
2. Check database connection
3. Rebuild infrastructure
4. Check if custom organization overrides default users

### No Processes Listed

**Issue:** GET /API/bpm/process returns empty array

**Possible Causes:**
- Processes failed to deploy
- BAR files missing or invalid
- Deployment errors

**Solution:**
1. Check Bonita logs: `docker logs bonita | grep -i process`
2. Verify BAR files exist in artifact archive:
   ```bash
   unzip -l app/target/poc-cnaf-rh2026-1.0.0-presales.zip | grep .bar
   ```
3. Check for deployment errors
4. Rebuild and redeploy

## Verification Scripts

### Quick Health Check Script

```bash
#!/bin/bash
# quick-health-check.sh

echo "Checking Docker containers..."
docker ps --filter "name=bonita\|postgres\|mail" --format "{{.Names}}: {{.Status}}"

echo -e "\nChecking Bonita server..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/bonita/loginservice)
if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Bonita server is responding (HTTP $HTTP_CODE)"
else
    echo "✗ Bonita server is not accessible (HTTP $HTTP_CODE)"
fi

echo -e "\nChecking artifact..."
if [ -f app/target/poc-cnaf-rh2026-1.0.0-presales.zip ]; then
    SIZE=$(ls -lh app/target/poc-cnaf-rh2026-1.0.0-presales.zip | awk '{print $5}')
    echo "✓ Artifact exists ($SIZE)"
else
    echo "✗ Artifact not found"
fi
```

### Process Status Check Script

```bash
#!/bin/bash
# check-processes.sh

echo "Logging in to Bonita..."
curl -s -c /tmp/bonita-cookies.txt \
  -d 'username=install&password=install&redirect=false' \
  http://localhost:8080/bonita/loginservice > /dev/null

API_TOKEN=$(grep X-Bonita-API-Token /tmp/bonita-cookies.txt | awk '{print $7}')

echo "Fetching processes..."
PROCESSES=$(curl -s -b /tmp/bonita-cookies.txt \
  -H "X-Bonita-API-Token: $API_TOKEN" \
  http://localhost:8080/bonita/API/bpm/process)

echo "$PROCESSES" | jq -r '.[] | "\(.name) v\(.version): \(.activationState)"'

rm /tmp/bonita-cookies.txt
```

## Performance Checks

### Response Time

Check Bonita server response time:

```bash
time curl -s -o /dev/null http://localhost:8080/bonita/loginservice
```

**Expected:** < 1 second

### Container Resource Usage

Check resource consumption:

```bash
docker stats bonita --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**Typical Values:**
- CPU: 5-15%
- Memory: 1-2 GB

### Database Connection

Test database connectivity:

```bash
docker exec postgres psql -U bonita -d bonita -c "SELECT current_database();"
```

**Expected:** Returns `bonita`

## Next Steps

After successful verification:

1. **Access Application**
   - Open http://localhost:8080/bonita
   - Login with install/install
   - Navigate to processes

2. **Test Process Instantiation**
   - Go to BPM → Processes
   - Click on a process
   - Click "Instantiate" or "Start"
   - Verify process case is created

3. **Review Deployed Artifacts**
   - Check Organization → Users
   - Check Data → Business Data Model
   - Check Organization → Profiles

4. **Monitor Logs**
   - Keep terminal open with: `docker logs bonita -f`
   - Watch for errors or warnings

## Notes

- Verification is optional but recommended for first deployment
- All checks can be automated in CI/CD pipelines
- Container health checks run automatically every 30 seconds
- Bonita server takes 30-60 seconds to fully start after container launch
- Use `docker logs bonita -f` to watch real-time logs during startup

---

**Deployment verification complete!**

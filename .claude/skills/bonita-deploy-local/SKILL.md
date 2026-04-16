---
name: bonita-deploy-local
description: Deploy Bonita application artifacts to a local Bonita server via Docker Compose. Use when the user wants to deploy, build and deploy, or launch the application locally.
disable-model-invocation: true
argument-hint: "[--skip-build] [--url <url>] [--username <user>] [--password <pass>]"
allowed-tools: Bash, Read, Glob
---

Deploy Bonita application artifacts to a local Bonita Studio server using the bonita-la-deployer tool.

This skill automates the deployment process by building the project (if needed), locating artifacts, and deploying them to the local Bonita runtime.

## Usage

```bash
# Deploy with default settings (builds project first)
/bonita-deploy-local

# Deploy without building (use existing artifacts)
/bonita-deploy-local --skip-build

# Deploy to specific URL
/bonita-deploy-local --url http://localhost:8080/bonita

# Deploy with custom credentials
/bonita-deploy-local --username install --password install
```

## Parameters

- `--skip-build` - Skip Maven build, use existing artifacts in app/target/
- `--url <url>` - Target Bonita server URL (default: `http://localhost:8080/bonita`)
- `--username <user>` - Bonita username (default: `install`)
- `--password <pass>` - Bonita password (default: `install`)

## Prerequisites

- Maven (mvnw) available in project root
- Local Bonita Studio/Runtime server running
- Target server accessible at specified URL
- Valid credentials for target server
- Internet connection (to download bonita-la-deployer if not present)

## What This Skill Does

The `infrastructure/build.sh` script is a comprehensive deployment tool that handles **all deployment steps** in a single execution:

1. **Build & Package**:
   - Runs `./mvnw clean package -Pdocker -Dbonita.environment=presales`
   - Generates Docker image and .zip artifact
   - Uses presales environment configuration

2. **Infrastructure Setup**:
   - Starts Docker Compose services (Bonita, PostgreSQL, Mail)
   - Deploys application automatically
   - Runs health checks

3. **Artifact Deployment** (automatic):
   - Deploys organization structure
   - Deploys processes (as .bar files)
   - Installs profiles
   - Deploys BDM
   - Installs pages and themes
   - Deploys REST API extensions

4. **Process Enablement** (automatic):
   - All deployed processes are automatically enabled
   - No manual intervention required

**Note:** The infrastructure script replaces the traditional bonita-la-deployer approach by deploying directly through Docker Compose.

## Global Directives

**IMPORTANT**: This skill assumes a running Bonita server at the target URL. Ensure Bonita Studio or Bonita Runtime is started before running this skill.

**Default Configuration:**
- Build script: `infrastructure/build.sh`
- Target URL: `http://localhost:8080/bonita`
- Username: `install`
- Password: `install`
- Development mode: enabled

## Execution Steps

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--skip-build`, `--url`, `--username`, `--password`) before starting.

### Step 1: Run Infrastructure Build & Deploy
[Read detailed instructions](steps/01-build-deploy.md)
- Check if `--skip-build` flag is set
- If not skipped: execute `infrastructure/build.sh`
- The script automatically performs:
  - Maven build with Docker profile
  - Docker Compose infrastructure startup
  - Application deployment
  - Process enablement
- Verify health checks pass
- Display deployment summary

### Step 2: Verify Deployment (Optional)
[Read detailed instructions](steps/02-verify-deployment.md)

**Quick Verification Commands:**

```bash
# Check Docker containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "bonita|postgres|mail|NAMES"

# Test Bonita server
curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/bonita/loginservice"
# Expected: 401 (server is running)

# Login and list processes
curl -s -c /tmp/bonita-cookies.txt -d 'username=install&password=install&redirect=false' http://localhost:8080/bonita/loginservice
API_TOKEN=$(grep X-Bonita-API-Token /tmp/bonita-cookies.txt | awk '{print $7}')
curl -s -b /tmp/bonita-cookies.txt -H "X-Bonita-API-Token: $API_TOKEN" http://localhost:8080/bonita/API/bpm/process | jq -r '.[] | "\(.name) v\(.version): \(.activationState)"'
rm /tmp/bonita-cookies.txt

# Check artifact
ls -lh app/target/poc-cnaf-rh2026-*.zip
```

**Verification tasks:**
- Check Docker containers are running
- Verify Bonita server is accessible
- List deployed processes and their states
- Confirm processes are enabled
- Display artifact information
- Display access URLs

**Automated Verification Script:**
```bash
.claude/skills/bonita-deploy-local/verify.sh
```

This script performs all verification checks automatically and provides a comprehensive report.

## Deployment Command

### Infrastructure Build & Deploy

The skill executes the comprehensive deployment script:

```bash
cd infrastructure && ./build.sh
```

**What the script does:**
1. Docker login to bonitasoft.jfrog.io
2. Clean up existing containers: `docker compose down -v`
3. Remove old Docker images
4. Run Maven: `./mvnw bonita-project:install`
5. Build with Docker profile: `./mvnw clean package -Pdocker -Dbonita.environment=presales`
6. Start infrastructure: `docker compose up -d`
7. Run health checks: `./healthz.sh`
8. **Automatic deployment of all artifacts**
9. **Automatic process enablement**

**Environment Variables Used:**
- `BONITA_ENVIRONMENT=presales`
- `BONITA_PROJECT_NAME` (from .env file)
- `BONITA_PROJECT_VERSION` (from .env file)

**Docker Compose Services:**
- Bonita server (with auto-deployment)
- PostgreSQL database
- Mail server

**Note:** Process enablement is built into the Docker container initialization, not done via REST API.

## Output

The skill provides deployment status:

### Successful Deployment

```
Deployment Successful
=====================

Script: infrastructure/build.sh
Environment: presales
Docker Image: poc-cnaf-rh2026:1.0.0

Deployed Components:
✓ Organization: CNAF_organization.xml
✓ Processes: ValidationRecrutement--1.6.bar, ValidationRecrutementZ--1.4.bar
✓ Profiles: default_profile.xml, CNAF_profiles.xml
✓ BDM: bdm.zip
✓ Pages: 16 pages deployed
✓ Theme: presales-template
✓ Extensions: reportingRestAPI

Docker Services:
✓ bonita: Running (http://localhost:8080/bonita)
✓ postgres: Running
✓ mail: Running

Health Check: PASSED
Processes: Automatically enabled

Application is ready at: http://localhost:8080/bonita
```

### Failed Deployment

```
Deployment Failed
=================

Error: Connection refused to http://localhost:8080/bonita

Possible causes:
- Bonita server is not running
- Incorrect URL or port
- Firewall blocking connection

Please ensure Bonita Studio/Runtime is started and try again.
```

## Quick Verification

After deployment, verify with these commands:

```bash
# 1. Check containers are running
docker ps | grep -E "bonita|postgres|mail"

# 2. Test Bonita server
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/bonita/loginservice
# Expected: 401 or 200

# 3. List processes via REST API
curl -s -c /tmp/cookies.txt -d 'username=install&password=install&redirect=false' http://localhost:8080/bonita/loginservice
API_TOKEN=$(grep X-Bonita-API-Token /tmp/cookies.txt | awk '{print $7}')
curl -s -b /tmp/cookies.txt -H "X-Bonita-API-Token: $API_TOKEN" http://localhost:8080/bonita/API/bpm/process | jq -r '.[] | "\(.name) v\(.version): \(.activationState)"'
rm /tmp/cookies.txt

# 4. Open Bonita Portal
open http://localhost:8080/bonita
# Login: install / install
```

## Common Scenarios

### Scenario 1: Quick Local Deploy

Deploy to local Bonita Studio during development:

```bash
# Build and deploy in one command
/bonita-deploy-local
```

### Scenario 2: Rapid Iteration

If Docker services are already running and you only need to rebuild:

```bash
# Just rebuild without full infrastructure reset
cd infrastructure && ./build.sh
# Or use --skip-build if only verifying existing deployment
/bonita-deploy-local --skip-build
```

### Scenario 3: Deploy to Remote Server

Deploy to a remote Bonita server:

```bash
# Deploy to remote server with custom credentials
/bonita-deploy-local --url http://remote-server:8080/bonita --username admin --password admin123
```

### Scenario 4: After Process Generation

After generating process diagrams with `/bonita-generate-process`:

```bash
# 1. Generate process diagram
/bonita-generate-process --input docs/out/analyse-project.adoc

# 2. Copy .proc file to app/diagrams/
cp docs/artifacts/ProcessName-1.0.proc app/diagrams/

# 3. Build and deploy
/bonita-deploy-local
```

## Integration with Other Skills

This skill integrates well with artifact generation skills:

```bash
# Full workflow: Generate → Validate → Deploy
/bonita-generate                    # Generate all artifacts
/bonita-validate-artifacts          # Validate XSD compliance

# Copy artifacts to app/ structure
cp docs/artifacts/bom.xml app/bdm/
cp docs/artifacts/organization.xml app/organizations/
cp docs/artifacts/*.proc app/diagrams/
cp docs/artifacts/profile.xml app/profiles/

/bonita-deploy-local                # Build and deploy
```

## Error Handling

### Build Failures

If Maven build fails:
- Check console output for compilation errors
- Ensure all dependencies are available
- Verify environment configuration in `app/environments/`

### Artifact Not Found

If artifacts are missing:
- Run without `--skip-build` flag
- Check `app/target/` directory
- Verify Maven build completed successfully

### Connection Refused

If deployment fails with connection error:
- Ensure Bonita server is running
- Verify URL is correct (default: http://localhost:8080/bonita)
- Check server logs for errors

### Authentication Failed

If deployment fails with auth error:
- Verify username/password are correct
- Default credentials: install/install
- Check if user has deployment permissions

## Infrastructure Script Details

**Location:** `infrastructure/build.sh`

**Key Features:**
- Docker Compose orchestration
- Automated artifact deployment
- Health check verification
- Environment configuration
- Database initialization
- Mail server setup

**Docker Images Used:**
- `bonitasoft.jfrog.io/docker-releases/bonita-subscription` (base image)
- Custom project image (built from project)
- PostgreSQL (database)
- Mail server (for notifications)

**Configuration Files:**
- `infrastructure/sca/.env-local-laurent` - Environment variables
- `infrastructure/sca/docker-compose-*.yml` - Service definitions

## Development Mode

The infrastructure script operates in **development mode** by default:
- Uses Docker Compose for local development
- Automatically replaces existing artifacts
- Hot-reload capabilities (depending on configuration)
- Persists data in Docker volumes
- Useful for rapid iteration during development

**Important:** This setup is for local development only. Production deployments use different tooling.

## Notes

- The infrastructure script handles **complete deployment** (build + deploy + enable)
- Deployment is idempotent (can be run multiple times safely)
- First run takes longer (60-180 seconds) - downloads Docker images, builds project
- Subsequent runs are faster (30-60 seconds) - uses cached images
- Docker must be running and logged into bonitasoft.jfrog.io
- All processes are **automatically enabled** by the Docker container
- The `tools/enable-processes/enable-processes.sh` script is **not needed** - processes are enabled during container startup
- Docker volumes persist data between restarts

## Troubleshooting

### Issue: Server Not Responding

**Solution:**
1. Verify Bonita Studio/Runtime is running
2. Check server logs: `<bonita-home>/server/logs/bonita.log`
3. Test server accessibility: `curl http://localhost:8080/bonita/loginservice`

### Issue: Deployment Hangs

**Solution:**
1. Check server resource usage (CPU, memory)
2. Review bonita-la-deployer logs
3. Restart Bonita server if needed
4. Retry deployment

### Issue: Artifacts Invalid

**Solution:**
1. Run `/bonita-validate-artifacts` before deployment
2. Check XSD validation errors
3. Regenerate artifacts if needed
4. Rebuild project

## See Also

- `/bonita-generate` - Generate all Bonita artifacts
- `/bonita-validate-artifacts` - Validate artifacts before deployment
- `deploy.sh` - Manual deployment script
- `CLAUDE.md` - Project build and deployment instructions

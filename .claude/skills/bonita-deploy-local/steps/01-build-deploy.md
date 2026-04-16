# Step 1: Build & Deploy

Execute the infrastructure build script to build, deploy, and configure the complete Bonita application environment.

## Objective

Run `infrastructure/build.sh` which performs a comprehensive deployment including building the project, starting Docker services, deploying all artifacts, and enabling processes automatically.

## Prerequisites

- Docker installed and running
- Logged into bonitasoft.jfrog.io: `docker login bonitasoft.jfrog.io`
- Build script `infrastructure/build.sh` exists and is executable
- Environment file exists: `infrastructure/sca/.env-local-laurent`
- Project is in valid state (no compilation errors)
- All dependencies are accessible

## Instructions

### 1. Check Skip Build Flag

Check if user provided `--skip-build` flag:
- If flag is set: Skip this step entirely and proceed to Step 2 (verification only)
- If flag is not set: Continue with build and deployment process

### 2. Execute Infrastructure Script

Run the comprehensive build and deployment script:

```bash
cd infrastructure && ./build.sh
```

**The script performs these operations automatically:**

1. **Docker Login**
   ```bash
   docker login bonitasoft.jfrog.io
   ```

2. **Cleanup**
   ```bash
   docker compose down -v --remove-orphans
   docker image rm ${BONITA_PROJECT_NAME}:${BONITA_PROJECT_VERSION}
   ```

3. **Maven Install**
   ```bash
   ./mvnw bonita-project:install
   ```

4. **Build with Docker Profile**
   ```bash
   ./mvnw clean package \
     -Pdocker \
     -Dbonita.environment=presales \
     -Ddocker.baseImageRepository=bonitasoft.jfrog.io/docker-releases/bonita-subscription \
     -Ddocker.imageName=${BONITA_PROJECT_NAME}:${BONITA_PROJECT_VERSION}
   ```

5. **Validate Docker Compose Configuration**
   ```bash
   docker compose config
   ```

6. **Start Infrastructure Services**
   ```bash
   docker compose up -d
   ```

   Services started:
   - Bonita server (with auto-deployment)
   - PostgreSQL database
   - Mail server

7. **Health Check**
   ```bash
   ./healthz.sh
   ```
   Waits for services to be healthy before completing

8. **Automatic Artifact Deployment**

   The Bonita Docker container automatically deploys:
   - Organization structure (`CNAF_organization.xml`)
   - Business Data Model (`bdm.zip`)
   - Profiles (`default_profile.xml`, `CNAF_profiles.xml`)
   - Processes (`ValidationRecrutement--1.6.bar`, `ValidationRecrutementZ--1.4.bar`)
   - Pages (16 UI pages)
   - Theme (`presales-template`)
   - REST API extensions (`reportingRestAPI`)

9. **Process Enablement**

   Processes are automatically enabled during container initialization

### 3. Monitor Script Output

Watch for these key indicators:

**Success Indicators:**
```
[INFO] BUILD SUCCESS
+ docker compose ... up -d
Server is healthy
+ exit 0
```

**Built Artifacts:**
```
app/target/
├── poc-cnaf-rh2026-1.0.0-presales.zip    # Application archive
├── docker/                                # Docker context
└── classes/                               # Compiled classes
```

**Running Containers:**
```
CONTAINER ID   IMAGE                            STATUS
abc123def456   poc-cnaf-rh2026:1.0.0           Up (healthy)
def456ghi789   postgres:11                      Up
ghi789jkl012   mailhog/mailhog                  Up
```

### 4. Verify Build & Deployment Success

Check the script exit code:
- **Exit code 0**: Build and deployment successful, proceed to Step 2
- **Non-zero exit code**: Build or deployment failed, report error and abort

The script uses `set -e` flag, so it will exit immediately on any error.

### 5. Report Deployment Status

If successful, display comprehensive summary:

```
Deployment Successful
=====================

Script: infrastructure/build.sh
Environment: presales
Docker Image: poc-cnaf-rh2026:1.0.0
Build Duration: ~90 seconds

Generated Artifacts:
✓ Application archive: app/target/poc-cnaf-rh2026-1.0.0-presales.zip (9.8 MB)
✓ Docker image: poc-cnaf-rh2026:1.0.0

Deployed Components:
✓ Organization: CNAF_organization.xml
✓ Processes:
  - ValidationRecrutement--1.6.bar
  - ValidationRecrutementZ--1.4.bar
✓ Profiles: default_profile.xml, CNAF_profiles.xml
✓ BDM: bdm.zip
✓ Pages: 16 pages
✓ Theme: presales-template
✓ Extensions: reportingRestAPI-2.0.0

Docker Services:
✓ bonita: Running and healthy
✓ postgres: Running
✓ mail: Running

Health Check: PASSED
Processes: Automatically enabled

Application is ready at: http://localhost:8080/bonita
```

## Error Handling

### Common Build Errors

#### Docker Not Running

**Error:** `Cannot connect to the Docker daemon`

**Solution:**
- Start Docker Desktop: `open -a Docker` (macOS)
- Verify Docker is running: `docker ps`
- Wait for Docker to fully start

#### Docker Login Required

**Error:** `unauthorized: authentication required`

**Solution:**
- Login to JFrog: `docker login bonitasoft.jfrog.io`
- Enter your credentials when prompted
- Verify login: `docker info | grep Username`

#### Compilation Errors

**Error:** Java compilation failures in Maven output

**Solution:**
- Review compilation errors in Maven output
- Check Java source files for syntax errors
- Ensure all dependencies are in pom.xml
- Clean and retry: `./mvnw clean`

#### Dependency Resolution Failures

**Error:** `Could not resolve dependencies`

**Solution:**
- Check internet connectivity
- Verify Maven settings.xml configuration
- Check repository is accessible
- Force update: `./mvnw clean package -U`

#### Port Already in Use

**Error:** `port is already allocated`

**Solution:**
- Stop conflicting services using ports 8080, 5432, 1025
- Or stop existing containers: `docker compose down`
- Verify ports are free: `lsof -i :8080`

#### Out of Memory

**Error:** `Java heap space` or `OutOfMemoryError`

**Solution:**
- Increase Maven memory: `export MAVEN_OPTS="-Xmx2g"`
- Increase Docker memory in Docker Desktop settings (recommend 8GB+)
- Close other applications
- Retry build

#### Environment File Not Found

**Error:** `infrastructure/sca/.env-local-laurent: No such file or directory`

**Solution:**
- Verify environment file exists
- Check path in build.sh script
- Create from template if missing

#### Health Check Fails

**Error:** `Health check failed` or timeout

**Solution:**
- Check Bonita logs: `docker logs <container-id>`
- Verify database connection
- Increase health check timeout in script
- Check system resources (CPU, memory)

### Docker Compose Errors

#### Image Pull Fails

**Error:** `Error response from daemon: pull access denied`

**Solution:**
- Verify JFrog credentials are valid
- Re-login: `docker login bonitasoft.jfrog.io`
- Check network connectivity
- Verify repository access permissions

#### Volume Mount Errors

**Error:** `invalid mount config`

**Solution:**
- Check Docker Compose file syntax
- Verify paths exist on host
- Check file permissions
- Use absolute paths if needed

## Expected Build Duration

[cols="1,2", options="header"]
|===
|Scenario |Duration

|First build (cold)
|120-180 seconds (downloads images, builds)

|Rebuild (warm)
|30-60 seconds (uses cached layers)

|No changes
|20-30 seconds (quick validation)
|===

## Docker Services Started

### Bonita Server

- **Container Name:** `bonita`
- **Image:** `poc-cnaf-rh2026:1.0.0`
- **Port:** `8080:8080`
- **Health Check:** HTTP GET to `/bonita/loginservice`
- **Auto-deploy:** Yes
- **Logs:** `docker logs bonita -f`

### PostgreSQL Database

- **Container Name:** `postgres`
- **Image:** `postgres:11`
- **Port:** `5432:5432`
- **Database:** `bonita`
- **Persistence:** Docker volume

### Mail Server

- **Container Name:** `mail`
- **Image:** `mailhog/mailhog`
- **Port:** `1025:1025` (SMTP), `8025:8025` (Web UI)
- **Purpose:** Capture emails sent by Bonita

## Generated Artifacts

After successful execution, these artifacts exist:

```
app/target/
├── poc-cnaf-rh2026-1.0.0-presales.zip    # Deployable archive
├── docker/                                # Docker build context
│   └── Dockerfile                         # Generated Dockerfile
├── classes/                               # Compiled Java classes
└── [other build artifacts]

Docker Images:
├── poc-cnaf-rh2026:1.0.0                 # Custom project image
└── bonitasoft.jfrog.io/docker-releases/bonita-subscription:10.4.2
```

## Verification Commands

After script completes, verify deployment:

```bash
# Check containers are running
docker ps

# Check Bonita logs
docker logs bonita -f

# Test Bonita server
curl http://localhost:8080/bonita/loginservice

# Check database
docker exec postgres psql -U bonita -d bonita -c "\dt"

# View mail server UI
open http://localhost:8025
```

## Notes

- Build duration includes Docker image build time
- First run downloads base images (~2GB)
- Subsequent runs use cached Docker layers (faster)
- The script uses environment-specific configuration from `.env-local-laurent`
- Process enablement happens during container startup (no manual step required)
- All data persists in Docker volumes (survives container restarts)
- To completely reset: `docker compose down -v` (removes volumes)

## Next Step

Proceed to [Step 2: Verify Deployment](02-verify-deployment.md)

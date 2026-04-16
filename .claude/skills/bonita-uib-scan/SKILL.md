---
name: bonita-uib-scan
description: Scan and import UI Builder applications from local workspaces or GitHub. Use when the user wants to scan, find, import, or discover UI Builder applications from local or remote sources.
disable-model-invocation: true
allowed-tools: Bash, Read, Glob
---

Scan for existing UI Builder applications in local Bonita workspaces and GitHub repositories, then import selected application to the current project.

This skill helps you discover and reuse UI Builder applications from:
- **Local workspaces**: `~/bonita/workspaces/<VERSION>/<PROJECT>/uib/*.json`
- **GitHub**: bonitasoft-presales organization repositories

**Implementation:** This skill wraps the `scan-uib-apps.sh` tool script located in `tools/uib-scan/`.

## Usage

```bash
# Scan and import UI Builder applications
/bonita-uib-scan
```

## Execution Instructions

When this skill is invoked:

1. **Run the scanner script**:
   ```bash
   ./tools/uib-scan/scan-uib-apps.sh
   ```

2. **After successful import**, automatically invoke the `/bonita-uib-apps` skill to generate application descriptors:
   ```bash
   /bonita-uib-apps
   ```

The scanner script will:
1. Scan local Bonita workspaces for UIB applications
2. Search GitHub (bonitasoft-presales organization) for UIB applications
3. Display an interactive menu with all found applications
4. Copy the selected application to `app/web_applications/`

## Prerequisites

**Required:**
- Docker installed and running (for JSON parsing)

**Optional (for remote scan):**
- GitHub CLI (`gh`) installed and authenticated
- Without `gh`, only local scan is performed

To install GitHub CLI:
```bash
# macOS
brew install gh

# Linux
# See https://cli.github.com/

# Authenticate
gh auth login
```

## What This Skill Does

### Step 1: Scan Local Workspaces

Searches for UI Builder JSON files in:
```
~/bonita/workspaces/
  └── <VERSION>/
      └── <PROJECT>/
          └── uib/
              └── *.json
```

For each file found, extracts:
- `exportedApplication.name` - Application display name
- `exportedApplication.slug` - Application identifier

### Step 2: Scan GitHub Repositories

Uses GitHub CLI to search for:
- **Organization**: bonitasoft-presales
- **Path**: `uib/*.json`
- **Type**: Code

For each result, fetches the raw JSON and extracts metadata.

### Step 3: Interactive Selection

Displays a numbered menu of all found applications:

```
============================================
Available UI Builder Applications
============================================

 1) CNAF FEB (cnaf-feb) [2025.2-u2/poc-cnaf-rh2026]
 2) Team Management (team-management) [2025.2-u2/poc-cnaf-rh2026]
 3) HR Dashboard (hr-dashboard) [GitHub: bonitasoft-presales/hr-portal]
 4) Leave Management (leave-mgmt) [GitHub: bonitasoft-presales/leave-system]

============================================
Select application number (or 'q' to quit):
```

### Step 4: Import Application

After selection:
1. For **local files**: Copies directly to `app/web_applications/`
2. For **remote files**: Downloads from GitHub, then copies to `app/web_applications/`
3. Preserves original filename

### Step 5: Generate Descriptors

After successful import, the skill automatically runs:
```bash
/bonita-uib-apps
```

This generates the Living Application descriptor in `app/applications/UIB_applications.xml`.

## Execution Steps

The skill executes the `scan-uib-apps.sh` tool script with these steps:

### 1. Validate Docker Availability

Checks if Docker is installed and running (required for JSON parsing).

### 2. Scan Local Workspaces

```bash
find ~/bonita/workspaces -type f -path "*/uib/*.json"
```

For each JSON file:
- Extract `exportedApplication.name`
- Extract `exportedApplication.slug`
- Store file path

### 3. Scan GitHub (if gh CLI available)

```bash
gh search code \
  --owner bonitasoft-presales \
  --filename "*.json" \
  --path "uib"
```

For each result:
- Construct raw file URL
- Fetch JSON content
- Extract metadata
- Store download URL

### 4. Present Menu

Display numbered list with:
- Application name
- Application slug
- Source location (project or GitHub repo)

### 5. Process Selection

- Validate user input
- Download if remote file
- Copy to `app/web_applications/`
- Show success message with next steps

### 6. Generate Application Descriptors

After the scan script completes successfully, Claude automatically invokes:

```bash
/bonita-uib-apps
```

This generates the Living Application descriptor in `app/applications/UIB_applications.xml`.

## Output Examples

### Success - Local Application

```
============================================
Bonita UIB Application Scanner
============================================

[INFO] Scanning local workspaces...
[INFO] Found 2 local application(s)

[INFO] Scanning GitHub (bonitasoft-presales organization)...
[WARN] No remote applications found

============================================
Available UI Builder Applications
============================================

 1) CNAF FEB (cnaf-feb) [2025.2-u2/poc-cnaf-rh2026]
 2) Team Management (team-management) [2025.2-u2/poc-cnaf-rh2026]

============================================
Select application number (or 'q' to quit): 1

[INFO] Selected: CNAF FEB (cnaf-feb) [2025.2-u2/poc-cnaf-rh2026]
[INFO] Copying to app/web_applications/CNAF FEB.json
[OK] Application copied successfully

============================================
Application imported successfully ✓
============================================

Location: app/web_applications/CNAF FEB.json

Next steps:
  1. Run /bonita-uib-apps to generate application descriptors
  2. Build and deploy: ./mvnw clean package && ./deploy.sh
```

### Success - Remote Application

```
[INFO] Scanning GitHub (bonitasoft-presales organization)...
[INFO] Found 3 remote application(s)

============================================
Available UI Builder Applications
============================================

 1) HR Dashboard (hr-dashboard) [GitHub: bonitasoft-presales/hr-portal]

============================================
Select application number (or 'q' to quit): 1

[INFO] Selected: HR Dashboard (hr-dashboard) [GitHub: bonitasoft-presales/hr-portal]
[INFO] Downloading from GitHub...
[OK] Downloaded successfully
[INFO] Copying to app/web_applications/HR Dashboard.json
[OK] Application copied successfully
```

### No Applications Found

```
[INFO] Scanning local workspaces...
[WARN] No local applications found

[INFO] Scanning GitHub (bonitasoft-presales organization)...
[WARN] No remote applications found

[ERROR] No UI Builder applications found

Searched locations:
  - Local: ~/bonita/workspaces/*/*/uib/*.json
  - Remote: GitHub bonitasoft-presales organization
```

### GitHub CLI Not Available

```
[INFO] Scanning GitHub (bonitasoft-presales organization)...
[WARN] GitHub CLI (gh) not found. Skipping remote scan.
[INFO] Install gh CLI: https://cli.github.com/
```

### GitHub CLI Not Authenticated

```
[INFO] Scanning GitHub (bonitasoft-presales organization)...
[WARN] GitHub CLI not authenticated. Skipping remote scan.
[INFO] Run: gh auth login
```

## Common Scenarios

### Scenario 1: Import from Another Project

Import a UI Builder application from a different project in your workspace:

```bash
# Scan and select
/bonita-uib-scan

# Application is automatically added to current project
# Descriptors are generated via /bonita-uib-apps
```

### Scenario 2: Reuse from GitHub

Find and import a UI Builder application shared in the presales organization:

```bash
# Ensure gh CLI is authenticated
gh auth status

# Scan and import
/bonita-uib-scan

# Select application from GitHub results
# Downloaded and added to project
```

### Scenario 3: Browse Available Applications

Discover what UI Builder applications are available without importing:

```bash
# Run scan
/bonita-uib-scan

# Browse the menu
# Press 'q' to quit without importing
```

## Integration with Workflow

Typical workflow for importing applications:

```bash
# 1. Scan and import application
/bonita-uib-scan

# (Automatically runs /bonita-uib-apps)

# 2. Build project
./mvnw clean package -Dbonita.environment=presales

# 3. Deploy to local Bonita
/bonita-deploy-local

# 4. Access application at:
#    http://localhost:8080/bonita/apps/{slug}/
```

## Error Handling

### Docker Not Available

```
[ERROR] Docker not found

This tool requires Docker to be installed and running.
Please install Docker: https://docs.docker.com/get-docker/
```

**Resolution:** Install Docker and ensure it's running.

### Invalid Selection

```
[ERROR] Invalid selection
```

**Resolution:** Enter a valid number from the menu or 'q' to quit.

### Download Failure

```
[ERROR] Failed to download file
```

**Resolution:** Check network connectivity and GitHub authentication.

### Copy Failure

```
[ERROR] Failed to copy application
```

**Resolution:** Check write permissions for `app/web_applications/` directory.

## File Locations

| File | Purpose |
|------|---------|
| `tools/uib-scan/scan-uib-apps.sh` | Scanner script (implementation) |
| `app/web_applications/*.json` | Imported UI Builder applications |
| `app/applications/UIB_applications.xml` | Generated application descriptors |

## Technical Details

### JSON Metadata Extraction

Uses Docker with `jq` for reliable JSON parsing:

```bash
docker run --rm -i ghcr.io/jqlang/jq:latest -r '.exportedApplication.name' < app.json
```

### GitHub Search

Uses GitHub CLI code search:

```bash
gh search code \
  --owner bonitasoft-presales \
  --filename "*.json" \
  --path "uib" \
  --json repository,path
```

### Remote File Download

Constructs raw GitHub URLs:

```
https://raw.githubusercontent.com/{org}/{repo}/master/uib/{filename}.json
```

## Validation

The script validates:
- Docker availability
- JSON file parseability
- Required metadata fields (`name`, `slug`)
- File copy success

## Notes

- **GitHub authentication**: Required for accessing private repositories in bonitasoft-presales
- **Branch assumption**: Assumes `master` branch for raw file URLs (can be extended)
- **Duplicate filenames**: If importing application with same name, overwrites existing file
- **Network dependency**: Remote scan requires internet connectivity

## See Also

- `/bonita-uib-apps` - Generate application descriptors (called automatically)
- `/bonita-deploy-local` - Deploy applications to local Bonita server
- GitHub CLI documentation: https://cli.github.com/
- Bonita UI Builder documentation

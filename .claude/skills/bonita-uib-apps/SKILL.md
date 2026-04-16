---
name: bonita-uib-apps
description: Generate UIB Living Application descriptors (UIB_applications.xml) from JSON files. Use when the user wants to generate, create, or update Living Application descriptors for UI Builder apps.
argument-hint: "[--profile <name>] [--version <ver>] [--state <state>]"
allowed-tools: Bash, Read, Write, Glob
---

Generate Bonita Living Application descriptors for UI Builder applications based on JSON files in the web_applications folder.

This skill automatically creates applicationLink entries in the UIB_applications.xml file for each UI Builder application found in the project.

**Implementation:** This skill wraps the `generate-uib-apps.sh` tool script located in `tools/generate-uib-apps/`.

## Usage

```bash
# Generate application descriptors for all JSON files
/bonita-uib-apps

# Generate with custom profile
/bonita-uib-apps --profile Administrator

# Dry-run mode (preview without modifying files)
/bonita-uib-apps --dry-run
```

## Parameters

- `--profile <name>` - Profile to assign to applications (default: `User`)
- `--version <ver>` - Application version (default: `1.0`)
- `--state <state>` - Application state: ACTIVATED or DEACTIVATED (default: `ACTIVATED`)
- `--dry-run` - Show what would be generated without modifying files

## Prerequisites

- UI Builder application JSON files in `app/web_applications/` directory
- Target descriptor file: `app/applications/UIB_applications.xml`
- Docker installed and running (for JSON parsing via `ghcr.io/jqlang/jq:latest`)
- GitHub CLI (`gh`) installed and authenticated (for downloading application icons from private repository)

**IMPORTANT**: This skill uses Docker for all tooling. GitHub CLI is required for downloading icons from the private repository.

## What This Skill Does

The skill processes UI Builder applications exported from Bonita UI Builder:

1. **Downloads application icons** from private GitHub repository (`bonitasoft-presales/showroom-cloud`)
2. **Extracts icons** to `app/applications/` directory
3. **Scans for JSON files** in `app/web_applications/` directory
4. **Extracts application metadata**:
   - `slug` - Used as application token and icon filename
   - `name` - Used as display name
5. **Generates applicationLink entries** with icon paths in `UIB_applications.xml`
6. **Preserves XML structure** and formatting

## Application Descriptor Format

For each JSON file, generates an `<applicationLink>` entry with icon path:

```xml
<applicationLink token="{slug}" version="1.0" profile="User" state="ACTIVATED">
    <displayName>{name}</displayName>
    <iconPath>{slug}.png</iconPath>
</applicationLink>
```

**Icon Path Convention**: Icons are automatically named based on the application slug: `{slug}.png`

## Input: UI Builder JSON Files

UI Builder exports applications as JSON files with this structure:

```json
{
  "artifactJsonType": "APPLICATION",
  "exportedApplication": {
    "name": "CNAF FEB",
    "slug": "cnaf-feb",
    ...
  }
}
```

**Required fields:**
- `exportedApplication.name` - Application display name
- `exportedApplication.slug` - Application URL token

## Output: UIB_applications.xml

Generated Living Application descriptor with icon paths:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<applications xmlns="http://documentation.bonitasoft.com/application-xml-schema/1.1">
    <applicationLink token="cnaf-feb" version="1.0" profile="User" state="ACTIVATED">
        <displayName>CNAF FEB</displayName>
        <iconPath>cnaf-feb.png</iconPath>
    </applicationLink>
    <applicationLink token="team-management" version="1.0" profile="User" state="ACTIVATED">
        <displayName>Team Management</displayName>
        <iconPath>team-management.png</iconPath>
    </applicationLink>
</applications>
```

**Icon Files**: Icons are stored in `app/applications/` directory alongside the XML descriptor.

## Execution Steps

The skill executes the `generate-uib-apps.sh` tool script located in `tools/generate-uib-apps/`.

### Step 1: Parse Arguments

Parse command-line arguments from `$ARGUMENTS`:
- `--profile <name>` → PROFILE parameter (default: User)
- `--version <ver>` → VERSION parameter (default: 1.0)
- `--state <state>` → STATE parameter (default: ACTIVATED)
- `--dry-run` → DRY_RUN parameter (default: false)

### Step 2: Execute Tool Script

Run the generator script:

```bash
./tools/generate-uib-apps/generate-uib-apps.sh "$PROFILE" "$VERSION" "$STATE" "$DRY_RUN"
```

### Step 3: Display Results

The tool script:
1. Downloads `applicationLogos.zip` from private GitHub repository using `gh` CLI
2. Extracts icons to `app/applications/` directory
3. Scans `app/web_applications/` for JSON files
4. Extracts metadata (slug, name) from each file using `jq`
5. Generates `<applicationLink>` entries with icon paths (`{slug}.png`)
6. Writes to `app/applications/UIB_applications.xml`
7. Reports success or errors

**Icon Source**: `bonitasoft-presales/showroom-cloud/app/attachments/applicationLogos.zip`

For detailed implementation, see: `tools/generate-uib-apps/README.adoc`

## Example Workflow

### Starting State

```
app/web_applications/
  ├── CNAF FEB.json
  └── Team Management.json

app/applications/
  └── UIB_applications.xml (empty or missing)
```

### After Running Skill

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<applications xmlns="http://documentation.bonitasoft.com/application-xml-schema/1.1">
    <applicationLink token="cnaf-feb" version="1.0" profile="User" state="ACTIVATED">
        <displayName>CNAF FEB</displayName>
    </applicationLink>
    <applicationLink token="team-management" version="1.0" profile="User" state="ACTIVATED">
        <displayName>Team Management</displayName>
    </applicationLink>
</applications>
```

## Output Examples

### Success

```
============================================
Bonita UIB Application Descriptor Generator
============================================

[INFO] Scanning for UI Builder applications in: app/web_applications/

[INFO] Found 2 application(s):
  - CNAF FEB (cnaf-feb)
  - Team Management (team-management)

[INFO] Generating UIB_applications.xml...

[OK]   Generated applicationLink for: cnaf-feb
[OK]   Generated applicationLink for: team-management

[OK]   UIB_applications.xml updated successfully

========================================
Generated 2 application descriptors ✓
========================================

Profile: User
Version: 1.0
State: ACTIVATED

Output file: app/applications/UIB_applications.xml
```

### Dry-Run Mode

```
[DRY-RUN] Would generate UIB_applications.xml with 2 applications:

<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<applications xmlns="http://documentation.bonitasoft.com/application-xml-schema/1.1">
    <applicationLink token="cnaf-feb" version="1.0" profile="User" state="ACTIVATED">
        <displayName>CNAF FEB</displayName>
        <iconPath>cnaf-feb.png</iconPath>
    </applicationLink>
    <applicationLink token="team-management" version="1.0" profile="User" state="ACTIVATED">
        <displayName>Team Management</displayName>
        <iconPath>team-management.png</iconPath>
    </applicationLink>
</applications>

[DRY-RUN] No files modified. Run without --dry-run to apply changes.
```

### No Applications Found

```
[WARN] No JSON files found in app/web_applications/

Please ensure:
  - UI Builder applications are exported to app/web_applications/
  - JSON files have .json extension
  - Files contain valid UI Builder application exports
```

## Common Scenarios

### Scenario 1: Initial Setup

Generate descriptors for all UI Builder applications:

```bash
# Export applications from UI Builder to app/web_applications/
# Then generate descriptors
/bonita-uib-apps

# Check generated file
cat app/applications/UIB_applications.xml
```

### Scenario 2: Add New Application

After adding a new JSON file:

```bash
# Export new application to app/web_applications/
# Regenerate descriptors (overwrites existing file)
/bonita-uib-apps
```

### Scenario 3: Custom Profile Assignment

Generate with specific profile:

```bash
# Assign to Administrator profile
/bonita-uib-apps --profile Administrator

# Assign to custom profile
/bonita-uib-apps --profile "HR Manager"
```

### Scenario 4: Preview Changes

Check what would be generated:

```bash
# Dry-run mode
/bonita-uib-apps --dry-run

# If looks good, apply
/bonita-uib-apps
```

## Integration with Deployment

The generated `UIB_applications.xml` is deployed with the Bonita application:

```bash
# 1. Generate descriptors
/bonita-uib-apps

# 2. Build and deploy
./mvnw clean package
/bonita-deploy-local
```

## Error Handling

### Docker Not Available

If Docker is not installed or not running:
```
[ERROR] Docker not found

This tool requires Docker to be installed and running.
Please install Docker: https://docs.docker.com/get-docker/
```

### GitHub CLI Not Available

If GitHub CLI is not installed:
```
[WARN] GitHub CLI (gh) not found
       Install it from: https://cli.github.com/
       Continuing without icons...
```

### GitHub Authentication Required

If GitHub CLI is not authenticated:
```
[WARN] Failed to download icons from GitHub
       Make sure you're authenticated: gh auth login
       Continuing without icons...
```

To authenticate with GitHub CLI:
```bash
gh auth login
# Follow the prompts to authenticate via SSH
```

### Invalid JSON

If JSON file is malformed:
```
[ERROR] Failed to parse: app/web_applications/MyApp.json

Error: parse error: Invalid JSON

Please ensure the file is a valid UI Builder export.
```

### Missing Required Fields

If JSON lacks required fields:
```
[WARN] Skipping app/web_applications/MyApp.json
       Missing required field: exportedApplication.slug

Please re-export the application from UI Builder.
```

## Validation

The skill validates:
- JSON files are readable and parsable
- Required fields exist (`slug`, `name`)
- Slug format is valid (lowercase, hyphens, no spaces)
- Generated XML is well-formed

## XML Schema Compliance

Generated XML conforms to:
- **Schema:** `http://documentation.bonitasoft.com/application-xml-schema/1.1`
- **Root element:** `<applications>`
- **Child elements:** `<applicationLink>`

## Profile Assignment

Applications are assigned to profiles that control access:

| Profile | Access Level | Use Case |
|---------|-------------|----------|
| User | Standard users | General-purpose applications |
| Administrator | Admin users | Admin tools and dashboards |
| Custom | Specific roles | Specialized applications |

## State Management

Application states:
- **ACTIVATED** - Application visible and accessible
- **DEACTIVATED** - Application hidden from portal

## File Location

| File | Purpose |
|------|---------|
| `app/web_applications/*.json` | UI Builder application exports (input) |
| `app/applications/UIB_applications.xml` | Living Application descriptors (output) |
| `app/applications/*.png` | Application icon files (downloaded from GitHub) |

## Notes

- The skill **overwrites** `UIB_applications.xml` on each run
- To preserve custom entries, back up the file first
- UI Builder applications must be exported as JSON files
- Icon paths are **automatically generated** as `{slug}.png`
- Icons are downloaded from private GitHub repository (`bonitasoft-presales/showroom-cloud`)
- If icon filename doesn't match application slug, rename the icon file manually
- Applications are accessible at: `http://bonita-server/bonita/apps/{token}/`

## See Also

- `/bonita-deploy-local` - Deploy applications to local Bonita server
- Bonita Living Applications documentation
- UI Builder export/import guide

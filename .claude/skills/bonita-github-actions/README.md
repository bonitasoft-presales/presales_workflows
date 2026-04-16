# Bonita GitHub Actions Analysis Skill

Analyze and inspect GitHub Actions workflows in Bonita projects, with specialized support for `bonitasoft-presales/presales_workflows` reusable workflows.

## Usage

```bash
/bonita-github-actions
```

## Overview

This skill provides comprehensive analysis of GitHub Actions workflows with specialized support for:
- **Bonita project-specific configurations** (version-specific licence secrets)
- **presales_workflows integration** (reusable workflow version management)
- **Security best practices** (explicit secret passing validation)
- **Workflow health monitoring** (run status, error detection)

## What It Does

This skill performs comprehensive analysis of GitHub Actions workflows in `.github/workflows/`:

### 1. Workflow Analysis
- Lists all workflow files
- Identifies triggers (push, pull_request, schedule, etc.)
- Maps jobs and their dependencies
- Lists all steps in each job
- Identifies external actions used with versions

### 2. Remote Actions Detection
**Specifically checks for actions from `bonitasoft-presales/presales_workflows` repository:**
- Identifies which remote actions are used
- Shows the version/ref (commit SHA, tag, or branch)
- Lists which workflows use these actions

### 3. Version Checking
**Checks if newer versions of remote actions are available:**
- Queries the latest commits/tags in `bonitasoft-presales/presales_workflows`
- Compares current versions with latest available
- Reports if updates are available and what changed
- Offers to update workflows if newer versions found

### 4. Bonita-Specific Validation
**Special handling for Bonita licence secrets:**
- Validates licence secret naming matches project version
- Checks that `licence_base64` parameter uses version-specific secret (e.g., `LICENCE_V10_2_BASE64` for Bonita 10.2.x)
- Reads project version from `pom.xml` parent version
- Ensures organization secrets are properly configured

### 5. Health Checks
- Identifies deprecated actions
- Checks for missing secrets/variables
- Detects potential security concerns
- Suggests configuration improvements
- Validates explicit secret passing (best practice)

### 6. Workflow History
- Shows recent workflow runs and their status
- Displays execution history
- Reports failed runs and error messages
- Shows current build progress

## Output

The skill generates a comprehensive report including:
- Summary of all workflows with triggers
- Job dependency graphs
- External actions grouped by owner/repo
- **Highlighted section for `bonitasoft-presales/presales_workflows` actions**
- Version update recommendations
- Environment requirements (secrets, variables)

## Requirements

- `gh` CLI installed and authenticated
- Access to the repository
- Network access to query GitHub API for version checking

## Example Output

The skill generates a detailed markdown report with:

**Executive Summary**
```
✅ All workflows using latest version: v1.7.0
✅ Licence secret correctly configured: LICENCE_V10_2_BASE64
✅ Explicit secrets: All workflows use explicit secret passing
🔄 Current Status: Build running successfully
```

**Workflows Overview**
- Lists all 4 workflow files with triggers and job counts
- Dependency graphs showing job execution order

**Remote Actions Analysis**
```
All from bonitasoft-presales/presales_workflows@v1.7.0

reusable_prerequisites.yml → Used in build
reusable_create_server.yml → Used in build
reusable_deploy_sca.yml → Used in build (requires LICENCE_V10_2_BASE64)
... (10 total reusable workflows)
```

**Secrets Analysis**
```
12 Unique Secrets Required:
- AWS_PRIVATE_KEY (9 usages)
- JFROG_USER (6 usages)
- LICENCE_V10_2_BASE64 (1 usage) ← Version-specific
```

**Recent Runs**
```
🔄 Running: chore/add-claude-md (19:25:10)
  ✅ pre_requisites: Success
  ✅ create_server: Success
  🔄 build_sca: In Progress
```

## Why Bonita-Specific?

This skill is tailored for Bonita projects with:

1. **Version-Specific Licence Management**
   - Validates licence secret naming matches Bonita version
   - Prevents using wrong licence version
   - Example: `LICENCE_V10_2_BASE64` for Bonita 10.2.x

2. **presales_workflows Integration**
   - Tracks reusable workflows from `bonitasoft-presales/presales_workflows`
   - Checks for version updates (v1.7.0, v1.6.0, etc.)
   - Ensures consistent workflow patterns across presales projects

3. **Bonita CI/CD Pipeline Understanding**
   - Recognizes standard Bonita deployment stages (build SCA, deploy UIB, run IT, datagen)
   - Validates AWS infrastructure provisioning patterns
   - Checks for Bonita-specific secrets (JFROG, healthz, etc.)

## Use Cases

- **New project setup**: Verify workflows are configured correctly
- **Version upgrades**: Check if newer presales_workflows are available
- **Troubleshooting**: Identify why builds are failing
- **Security audit**: Ensure explicit secrets and best practices
- **Documentation**: Generate comprehensive workflow documentation

## Related Skills

- `/bonita-gen-docs` - Generate process documentation
- `/bonita-gen-bdm-diagram` - Generate BDM ER diagrams

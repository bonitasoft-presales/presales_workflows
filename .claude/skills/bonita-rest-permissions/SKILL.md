---
name: bonita-rest-permissions
description: Validate and manage REST API extension permissions in Bonita projects. Use when the user wants to check, validate, fix, or manage REST API permissions mappings.
argument-hint: "[--fix] [--extension <name>] [--dry-run]"
allowed-tools: Read, Write, Bash, Glob, Grep
---

Validate that all REST API extension permissions are properly mapped in the custom permissions configuration file.

This skill ensures compliance with Bonita security requirements by checking that every permission declared in REST API extensions has a corresponding mapping to profiles or users.

## Usage

```bash
# Validate all REST API permissions
/bonita-rest-permissions

# Validate and auto-fix missing permissions
/bonita-rest-permissions --fix

# Validate specific extension
/bonita-rest-permissions --extension reportingRestAPI

# Dry-run mode (show what would be fixed without making changes)
/bonita-rest-permissions --fix --dry-run
```

## Parameters

- `--fix` - Automatically add missing permissions to custom-permissions-mapping.properties
- `--extension <name>` - Validate only a specific extension (optional)
- `--dry-run` - Show what would be changed without making modifications (requires --fix)

## Prerequisites

- Project follows standard Bonita structure
- REST API extensions in `extensions/` directory (optional)
- Built application ZIP in `app/target/*.zip` (for dependency scanning)
- Permission mapping file: `infrastructure/sca/customPermissions/custom-permissions-mapping.properties`

## What This Skill Does

According to `context-ia/05-rest-api-permissions.mdc`, this skill validates permissions from three sources:

1. **Local Extensions**: Scans `extensions/*/src/main/resources/page.properties`
2. **Built Extension ZIPs**: Checks `extensions/*/target/*.zip`
3. **Maven Dependencies**: Scans REST API extensions in `~/.m2/repository/**/custompage*.zip`

For each REST API extension found, it:
- Identifies the extension by `contentType=apiExtension` in `page.properties`
- Extracts all `*.permissions=` declarations
- Validates each permission is mapped in `custom-permissions-mapping.properties`
- Reports missing or unmapped permissions
- Optionally adds missing permissions to appropriate profiles (with --fix)

## Global Directives

**IMPORTANT**: Follow the validation rules from `context-ia/05-rest-api-permissions.mdc`:

1. **Every REST API endpoint MUST declare permissions** in page.properties
2. **All declared permissions MUST be mapped** to profiles or users
3. **Permission names must be lowercase with underscores** (e.g., `task_visualization`)
4. **Prefer mapping to profiles** over individual users
5. **Follow permission naming conventions**:
   - `{entity}_visualization` for read/view operations
   - `{entity}_management` for create/update operations
   - `{entity}_deletion` for delete operations
   - `admin_{scope}` for admin operations

## Execution Steps

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--fix`, `--extension`, `--dry-run`) before starting.

### Step 1: Load Permission Mappings
[Read detailed instructions](steps/01-load-mappings.md)
- Read `infrastructure/sca/customPermissions/custom-permissions-mapping.properties`
- Parse `profile|{ProfileName}=[permission1,permission2,...]` entries
- Parse `user|{username}=[permission1,permission2,...]` entries
- Build list of all currently mapped permissions

### Step 2: Scan Local Extensions
[Read detailed instructions](steps/02-scan-local.md)
- Find all `extensions/*/src/main/resources/page.properties` files
- For each page.properties:
  - Check if `contentType=apiExtension`
  - Extract all `*.permissions=` declarations
  - Parse comma-separated permission lists
  - Record extension name and permissions

### Step 3: Scan Built Extension ZIPs
[Read detailed instructions](steps/03-scan-built.md)
- Find all `extensions/*/target/*.zip` files
- For each ZIP:
  - Extract page.properties from ZIP
  - Check if REST API extension (contentType=apiExtension)
  - Extract permissions
  - Record extension name and permissions

### Step 4: Scan Maven Dependencies
[Read detailed instructions](steps/04-scan-maven.md)
- Extract application ZIP from `app/target/*.zip`
- Find all `extensions/custompage*.zip` within application ZIP
- For each extension ZIP:
  - Extract page.properties
  - Check if REST API extension
  - Extract permissions
  - Record extension name and permissions

### Step 5: Validate Permissions
[Read detailed instructions](steps/05-validate.md)
- For each permission found:
  - Check if permission exists in loaded mappings
  - If not mapped:
    - Mark as ERROR
    - Record source extension(s)
  - If mapped:
    - Mark as OK
    - Record which profile(s)/user(s) have it

### Step 6: Generate Report
[Read detailed instructions](steps/06-generate-report.md)
- Display validation summary:
  - Total extensions scanned
  - Total unique permissions found
  - Permissions properly mapped (✓)
  - Permissions missing mappings (✗)
- For each missing permission:
  - List source extensions
  - Suggest appropriate profile mappings
- Exit with status:
  - 0 = All permissions properly mapped
  - 1 = Missing mappings found

### Step 7: Auto-Fix (Optional)
[Read detailed instructions](steps/07-auto-fix.md)
- Only if `--fix` flag is provided
- For each missing permission:
  - Determine appropriate profile based on permission name:
    - `*_visualization` → Add to User profile
    - `*_management` → Add to User and Administrator profiles
    - `*_deletion` → Add to Administrator profile only
    - `admin_*` → Add to Administrator profile only
  - Add permission to selected profile(s)
  - Preserve file formatting and comments
- Write updated `custom-permissions-mapping.properties`
- Display summary of changes made

## Permission Mapping Strategy

When auto-fixing (--fix), use these rules:

| Permission Pattern | Profile Mapping | Rationale |
|-------------------|-----------------|-----------|
| `{entity}_visualization` | User, Administrator | Read access for standard users |
| `{entity}_management` | User, Administrator | Write access for users who manage entities |
| `{entity}_deletion` | Administrator | Delete requires elevated privileges |
| `admin_{scope}` | Administrator | Admin operations restricted to admins |
| `{custom}` | User | Default to User profile, can be refined later |

## Output

### Validation Success

```
============================================
REST API Extension Permissions Validation
============================================

[INFO] Mapped permissions found:
       - task_visualization
       - process_visualization
       - case_visualization
       - flownode_visualization

[INFO] Checking local extensions...
[INFO]   No local extensions found

[INFO] Checking built extension ZIPs...
[INFO]   No built ZIP files found

[INFO] Checking Maven dependency ZIPs...
[INFO]   Found REST API extension: reportingRestAPI-2.0.0
[INFO]     - getProcessesAPI: process_visualization
[INFO]     - getTaskGraphAPI: task_visualization
[INFO]     - exportTasksAPI: task_visualization
[INFO]     - getCaseAverageAPI: process_visualization, case_visualization, task_visualization, flownode_visualization
[INFO]     - exportCasesAPI: process_visualization, case_visualization, task_visualization, flownode_visualization

[INFO] Validating permissions...
[OK]    Permission 'process_visualization' is properly mapped
        Profiles: User, Administrator
[OK]    Permission 'task_visualization' is properly mapped
        Profiles: User, Administrator
[OK]    Permission 'case_visualization' is properly mapped
        Profiles: User, Administrator
[OK]    Permission 'flownode_visualization' is properly mapped
        Profiles: User, Administrator

========================================
All permissions are properly mapped ✓
========================================

Summary:
  Extensions scanned: 1
  Unique permissions: 4
  Properly mapped: 4
  Missing mappings: 0
```

### Validation Failure

```
============================================
REST API Extension Permissions Validation
============================================

[INFO] Mapped permissions found:
       - teamPermission

[INFO] Checking local extensions...
[INFO]   No local extensions found

[INFO] Checking built extension ZIPs...
[INFO]   No built ZIP files found

[INFO] Checking Maven dependency ZIPs...
[INFO]   Found REST API extension: reportingRestAPI-2.0.0
[INFO]     - getProcessesAPI: process_visualization
[INFO]     - getTaskGraphAPI: task_visualization
[INFO]     - exportTasksAPI: task_visualization
[INFO]     - getCaseAverageAPI: process_visualization, case_visualization, task_visualization, flownode_visualization
[INFO]     - exportCasesAPI: process_visualization, case_visualization, task_visualization, flownode_visualization

[INFO] Validating permissions...
[ERROR] Permission 'process_visualization' is declared but not mapped
        Sources: reportingRestAPI-2.0.0 (getProcessesAPI, getCaseAverageAPI, exportCasesAPI)
[ERROR] Permission 'task_visualization' is declared but not mapped
        Sources: reportingRestAPI-2.0.0 (getTaskGraphAPI, exportTasksAPI, getCaseAverageAPI, exportCasesAPI)
[ERROR] Permission 'case_visualization' is declared but not mapped
        Sources: reportingRestAPI-2.0.0 (getCaseAverageAPI, exportCasesAPI)
[ERROR] Permission 'flownode_visualization' is declared but not mapped
        Sources: reportingRestAPI-2.0.0 (getCaseAverageAPI, exportCasesAPI)

========================================
VALIDATION FAILED: Missing permission mappings ✗
========================================

The following permissions are declared but not mapped:
  - process_visualization (from: reportingRestAPI-2.0.0)
  - task_visualization (from: reportingRestAPI-2.0.0)
  - case_visualization (from: reportingRestAPI-2.0.0)
  - flownode_visualization (from: reportingRestAPI-2.0.0)

Please add the missing permissions to:
  infrastructure/sca/customPermissions/custom-permissions-mapping.properties

Example format:
  profile|User=[process_visualization,task_visualization,case_visualization,flownode_visualization]
  profile|Administrator=[process_visualization,task_visualization,case_visualization,flownode_visualization]

Or run with --fix to automatically add them:
  /bonita-rest-permissions --fix
```

### Auto-Fix Output

```
============================================
REST API Extension Permissions Auto-Fix
============================================

[INFO] Scanning for missing permissions...
[INFO] Found 4 missing permissions

[INFO] Adding missing permissions:
  + process_visualization → profile|User, profile|Administrator
  + task_visualization → profile|User, profile|Administrator
  + case_visualization → profile|User, profile|Administrator
  + flownode_visualization → profile|User, profile|Administrator

[INFO] Updating custom-permissions-mapping.properties...
[OK]   File updated successfully

========================================
Auto-fix completed successfully ✓
========================================

Summary:
  Permissions added: 4
  Profiles updated: User, Administrator

Please review the changes in:
  infrastructure/sca/customPermissions/custom-permissions-mapping.properties
```

## Common Scenarios

### Scenario 1: Pre-Commit Validation

Validate permissions before committing changes:

```bash
# Check if all permissions are mapped
/bonita-rest-permissions

# If validation fails, fix automatically
/bonita-rest-permissions --fix

# Commit changes
git add infrastructure/sca/customPermissions/custom-permissions-mapping.properties
git commit -m "Add missing REST API permissions"
```

### Scenario 2: After Adding New Extension

After adding a new REST API extension to the project:

```bash
# 1. Add extension module to extensions/
# 2. Implement REST API with page.properties

# 3. Validate permissions
/bonita-rest-permissions

# 4. Fix if needed
/bonita-rest-permissions --fix
```

### Scenario 3: Review Changes Before Applying

Use dry-run to see what would be changed:

```bash
# See what permissions would be added without modifying files
/bonita-rest-permissions --fix --dry-run

# If changes look good, apply them
/bonita-rest-permissions --fix
```

### Scenario 4: Validate Specific Extension

Validate permissions for a single extension:

```bash
# Validate only reportingRestAPI
/bonita-rest-permissions --extension reportingRestAPI
```

## Integration with Pre-Commit Hook

This skill can be integrated into the git pre-commit hook (`.githooks/pre-commit`) to automatically validate permissions before each commit.

The hook should:
1. Run this skill in validation mode (without --fix)
2. Block commit if validation fails
3. Provide instructions to fix issues

Example hook integration:

```bash
#!/bin/bash
# In .githooks/pre-commit

echo "Validating REST API permissions..."
if ! /bonita-rest-permissions; then
    echo "ERROR: Permission validation failed"
    echo "Run '/bonita-rest-permissions --fix' to resolve"
    exit 1
fi
```

## Error Handling

### Missing Permission Mapping File

If `infrastructure/sca/customPermissions/custom-permissions-mapping.properties` doesn't exist:
- Create it with default User and Administrator profiles
- Add comment header explaining the file purpose
- Proceed with validation

### Invalid page.properties Format

If a page.properties file has syntax errors:
- Log warning with file path
- Skip that extension
- Continue validation of other extensions

### Cannot Extract ZIP

If a ZIP file cannot be extracted:
- Log warning with ZIP path
- Skip that extension
- Continue validation

### Permission Naming Violations

If permission names don't follow conventions:
- Log warning with permission name
- Suggest correct naming format
- Include in validation report
- Do not block (naming is a warning, not an error)

## Validation Rules Reference

Based on `context-ia/05-rest-api-permissions.mdc`:

1. **Mandatory Permission Declaration** (BLOCKER)
   - Every REST API endpoint MUST declare `*.permissions=` in page.properties
   - Empty permissions are not allowed

2. **Permission Mapping Required** (BLOCKER)
   - All declared permissions MUST be mapped in custom-permissions-mapping.properties
   - Unmapped permissions will cause validation failure

3. **Naming Conventions** (WARNING)
   - Permission names should be lowercase with underscores
   - Should follow standard patterns: `{entity}_{operation}`
   - Violations generate warnings but don't block

4. **Profile Preference** (RECOMMENDATION)
   - Map to profiles rather than individual users
   - Improves maintainability
   - Follows least privilege principle

## Exit Codes

- **0**: All validations passed, all permissions properly mapped
- **1**: Validation failed, missing permission mappings found
- **2**: Invalid arguments or configuration error

## Notes

- This skill implements the validation logic described in `context-ia/05-rest-api-permissions.mdc` section 8
- Validation can run without building the project (uses existing artifacts)
- Maven dependency scanning requires application ZIP to be built
- The skill does not modify REST API extension code, only the permission mapping file
- Auto-fix uses conservative defaults; manual review is recommended
- Changes made by --fix should be reviewed before committing

## See Also

- `context-ia/05-rest-api-permissions.mdc` - Complete permission management documentation
- `.githooks/pre-commit` - Pre-commit hook integration
- `/bonita-deploy-local` - Deploy with permission mappings
- `infrastructure/sca/customPermissions/custom-permissions-mapping.properties` - Permission mapping file

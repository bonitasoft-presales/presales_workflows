# Step 5: Validate Permissions

Compare declared permissions against mapped permissions to identify missing mappings.

## Input

- Mapped permissions (from Step 1)
- Declared permissions from:
  - Local extensions (Step 2)
  - Built ZIPs (Step 3)
  - Maven dependencies (Step 4)

## Processing

1. Build complete list of unique permissions found across all sources

2. For each unique permission:

   a. Check if permission exists in mapped permissions

   b. If **MAPPED**:
   ```bash
   echo "[OK]    Permission '$PERMISSION' is properly mapped"
   echo "        Profiles: $(list_profiles_for_permission $PERMISSION)"
   ```

   c. If **NOT MAPPED**:
   ```bash
   echo "[ERROR] Permission '$PERMISSION' is declared but not mapped"
   echo "        Sources: $(list_sources_for_permission $PERMISSION)"
   VALIDATION_FAILED=true
   ```

3. Track validation statistics:
   - Total permissions found
   - Permissions properly mapped
   - Permissions missing mappings

## Validation Logic

```python
def validate_permission(permission, mapped_permissions):
    if permission in mapped_permissions:
        profiles = mapped_permissions[permission]
        return {
            "status": "OK",
            "permission": permission,
            "profiles": profiles
        }
    else:
        sources = get_sources_for_permission(permission)
        return {
            "status": "ERROR",
            "permission": permission,
            "sources": sources
        }
```

## Output Example (All Valid)

```
[INFO] Validating permissions...
[OK]    Permission 'process_visualization' is properly mapped
        Profiles: User, Administrator
[OK]    Permission 'task_visualization' is properly mapped
        Profiles: User, Administrator
[OK]    Permission 'case_visualization' is properly mapped
        Profiles: User, Administrator
[OK]    Permission 'flownode_visualization' is properly mapped
        Profiles: User, Administrator
```

## Output Example (Missing Mappings)

```
[INFO] Validating permissions...
[OK]    Permission 'teamPermission' is properly mapped
        Profiles: User
[ERROR] Permission 'process_visualization' is declared but not mapped
        Sources: reportingRestAPI-2.0.0 (getProcessesAPI, getCaseAverageAPI, exportCasesAPI)
[ERROR] Permission 'task_visualization' is declared but not mapped
        Sources: reportingRestAPI-2.0.0 (getTaskGraphAPI, exportTasksAPI, getCaseAverageAPI, exportCasesAPI)
[ERROR] Permission 'case_visualization' is declared but not mapped
        Sources: reportingRestAPI-2.0.0 (getCaseAverageAPI, exportCasesAPI)
[ERROR] Permission 'flownode_visualization' is declared but not mapped
        Sources: reportingRestAPI-2.0.0 (getCaseAverageAPI, exportCasesAPI)
```

## Validation Result

Return validation result structure:
```json
{
  "status": "FAILED",
  "total_permissions": 5,
  "mapped_count": 1,
  "unmapped_count": 4,
  "unmapped_permissions": [
    {
      "permission": "process_visualization",
      "sources": ["reportingRestAPI-2.0.0"],
      "endpoints": ["getProcessesAPI", "getCaseAverageAPI", "exportCasesAPI"]
    },
    {
      "permission": "task_visualization",
      "sources": ["reportingRestAPI-2.0.0"],
      "endpoints": ["getTaskGraphAPI", "exportTasksAPI", "getCaseAverageAPI", "exportCasesAPI"]
    }
  ]
}
```

## Additional Checks

### Permission Naming Validation

Check if permission names follow conventions:
```bash
if ! echo "$PERMISSION" | grep -qE '^[a-z_]+$'; then
    echo "[WARN]  Permission '$PERMISSION' does not follow naming convention"
    echo "        Expected: lowercase with underscores (e.g., 'task_visualization')"
fi
```

### Recommended Patterns

Suggest correct patterns for common permission types:
- Visualization: `{entity}_visualization`
- Management: `{entity}_management`
- Deletion: `{entity}_deletion`
- Admin: `admin_{scope}`

## Exit Status

- Set exit code based on validation result:
  - 0 if all permissions are mapped
  - 1 if any permissions are missing mappings

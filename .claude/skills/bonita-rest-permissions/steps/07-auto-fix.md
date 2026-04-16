# Step 7: Auto-Fix Missing Permissions

Automatically add missing permissions to the custom-permissions-mapping.properties file.

**IMPORTANT**: This step only executes if the `--fix` flag is provided.

## Input

- List of unmapped permissions (from Step 5)
- Current custom-permissions-mapping.properties content
- Target profiles (User, Administrator)

## Processing

1. **Dry-run check**:
   ```bash
   if [ "$DRY_RUN" = "true" ]; then
       echo "[INFO] DRY-RUN MODE: Showing what would be changed without making modifications"
   fi
   ```

2. **For each unmapped permission, determine target profile(s)**:

   ```bash
   determine_target_profiles() {
       PERMISSION=$1

       case "$PERMISSION" in
           *_visualization)
               echo "User Administrator"
               ;;
           *_management)
               echo "User Administrator"
               ;;
           *_deletion)
               echo "Administrator"
               ;;
           admin_*)
               echo "Administrator"
               ;;
           *)
               echo "User"
               ;;
       esac
   }
   ```

3. **Read current mappings and update**:

   a. Parse existing profile lines

   b. For each target profile:
      - Find the profile line (e.g., `profile|User=[...]`)
      - Extract current permissions list
      - Add new permission if not already present
      - Rebuild line with updated permissions

   c. If profile doesn't exist, create new line

4. **Preserve file structure**:
   - Keep comments in place
   - Maintain formatting
   - Sort permissions alphabetically within each profile (optional)
   - Add comment documenting when permissions were added

5. **Write updated file**:
   ```bash
   if [ "$DRY_RUN" = "true" ]; then
       echo "[DRY-RUN] Would update custom-permissions-mapping.properties"
       echo "[DRY-RUN] Changes:"
       diff <(cat custom-permissions-mapping.properties) <(echo "$NEW_CONTENT")
   else
       echo "$NEW_CONTENT" > custom-permissions-mapping.properties
       echo "[OK]   File updated successfully"
   fi
   ```

## Permission Assignment Strategy

| Permission Pattern | Profiles to Update | Rationale |
|-------------------|-------------------|-----------|
| `*_visualization` | User, Administrator | Standard read access for all users |
| `*_management` | User, Administrator | Write operations for active users |
| `*_deletion` | Administrator only | Destructive operations need admin rights |
| `admin_*` | Administrator only | Admin-scoped operations |
| Custom/Other | User | Conservative default, can be refined |

## Example Transformation

**Before:**
```properties
#Team Management
profile|User=[teamPermission]

#Administration
profile|Administrator=[admin_permission]
```

**After (adding process_visualization, task_visualization):**
```properties
#Team Management
profile|User=[teamPermission, process_visualization, task_visualization]

#Administration
profile|Administrator=[admin_permission, process_visualization, task_visualization]

#Reporting API Extension Permissions
# Auto-added by bonita-rest-permissions on 2026-01-29
# Required by reportingRestAPI-2.0.0
```

## Output Example

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

## Dry-Run Output

```
[DRY-RUN] Would add 4 permissions:
  + process_visualization → User, Administrator
  + task_visualization → User, Administrator
  + case_visualization → User, Administrator
  + flownode_visualization → User, Administrator

[DRY-RUN] File changes preview:
--- custom-permissions-mapping.properties (current)
+++ custom-permissions-mapping.properties (proposed)
@@ -1,4 +1,10 @@
 #Team Management
-profile|User=[teamPermission]
+profile|User=[teamPermission, process_visualization, task_visualization, case_visualization, flownode_visualization]

 #Administration
-profile|Administrator=[admin_permission]
+profile|Administrator=[admin_permission, process_visualization, task_visualization, case_visualization, flownode_visualization]
+
+#Reporting API Extension Permissions
+# Auto-added by bonita-rest-permissions
+# Required by reportingRestAPI-2.0.0

[DRY-RUN] No changes written. Run without --dry-run to apply.
```

## Profile Creation

If a profile doesn't exist in the file, create it:

```properties
# Auto-created by bonita-rest-permissions
profile|User=[process_visualization, task_visualization]
profile|Administrator=[process_visualization, task_visualization, case_visualization, flownode_visualization, admin_permission]
```

## Error Handling

- **File write permission denied**: Log error, exit with code 2
- **Invalid file format**: Log error, suggest manual fix
- **Duplicate permissions**: Silently skip (idempotent operation)

## Post-Fix Actions

After successful fix:
1. Display summary of changes
2. Show file path for review
3. Suggest running validation again to confirm
4. Remind user to review and commit changes

```bash
echo ""
echo "Next steps:"
echo "  1. Review changes: cat infrastructure/sca/customPermissions/custom-permissions-mapping.properties"
echo "  2. Validate again: /bonita-rest-permissions"
echo "  3. Commit changes: git add infrastructure/sca/customPermissions/custom-permissions-mapping.properties"
```

## Notes

- Auto-fix uses conservative defaults
- Manual review is recommended after auto-fix
- Changes should be committed to version control
- The fix is idempotent (safe to run multiple times)

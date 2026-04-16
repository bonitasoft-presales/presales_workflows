# Step 1: Load Permission Mappings

Read and parse the existing permission mappings from the custom permissions configuration file.

## Input

- File: `infrastructure/sca/customPermissions/custom-permissions-mapping.properties`

## Processing

1. Check if the file exists:
   ```bash
   if [ ! -f infrastructure/sca/customPermissions/custom-permissions-mapping.properties ]; then
       echo "[WARN] Permission mapping file not found, will be created if --fix is used"
   fi
   ```

2. Read the file and parse permission entries:
   - Lines starting with `#` are comments (skip)
   - Lines matching `profile|{ProfileName}=[...]` are profile mappings
   - Lines matching `user|{username}=[...]` are user mappings
   - Extract comma-separated permission lists from brackets

3. Build a data structure of mapped permissions:
   ```
   {
     "task_visualization": ["profile:User", "profile:Administrator"],
     "process_visualization": ["profile:User", "profile:Administrator"],
     "teamPermission": ["profile:User"]
   }
   ```

## Example File Format

```properties
#Team Management
profile|User=[teamPermission, process_visualization, task_visualization]

#Administration
profile|Administrator=[process_visualization, task_visualization, admin_permission]

#Specific user (rare)
user|john.doe=[special_permission]
```

## Output

- Dictionary/map of all currently mapped permissions
- List of profiles that exist in the file
- Count of mapped permissions

## Example Output

```
[INFO] Loaded permission mappings from custom-permissions-mapping.properties
[INFO] Profiles found: User, Administrator, Ticketing Reporter, Customer, RepairAgent
[INFO] Total mapped permissions: 8
       - teamPermission (User)
       - process_visualization (User, Administrator)
       - task_visualization (User, Administrator)
       - case_visualization (User, Administrator)
       - flownode_visualization (User, Administrator)
       - bdm_visualization (Ticketing Reporter, Customer, RepairAgent)
       - case_activity (Customer, RepairAgent)
       - application_visualization (Customer, RepairAgent)
```

## Error Handling

- If file doesn't exist: Warn but continue (empty mappings list)
- If file has syntax errors: Log warning and skip malformed lines
- If duplicate permissions exist: Use union of all mappings

# Step 4: Scan Maven Dependencies

Scan REST API extensions included as Maven dependencies in the application bundle.

## Input

- Application ZIP: `app/target/{project-name}-{version}-{environment}.zip`
- Extension location within ZIP: `extensions/custompage*.zip`

## Processing

1. Find the application ZIP file:
   ```bash
   APP_ZIP=$(ls -t app/target/*.zip | head -1)
   if [ -z "$APP_ZIP" ]; then
       echo "[WARN] No application ZIP found in app/target/"
       return
   fi
   echo "[INFO] Checking Maven dependency ZIPs in: $APP_ZIP"
   ```

2. List extension ZIPs within the application ZIP:
   ```bash
   unzip -l "$APP_ZIP" | grep "extensions/.*\.zip" | grep -v theme
   ```

3. For each extension ZIP found:

   a. Extract to temporary directory:
   ```bash
   TEMP_DIR=$(mktemp -d)
   unzip -q "$APP_ZIP" "extensions/*.zip" -d "$TEMP_DIR"
   ```

   b. For each extracted ZIP:
   ```bash
   for EXT_ZIP in "$TEMP_DIR"/extensions/*.zip; do
       EXT_NAME=$(basename "$EXT_ZIP" .zip)

       # Extract page.properties from extension ZIP
       unzip -q -o "$EXT_ZIP" page.properties -d "$TEMP_DIR/ext"

       # Check if it's a REST API extension
       if grep -q "contentType=apiExtension" "$TEMP_DIR/ext/page.properties"; then
           echo "[INFO]   Found REST API extension: $EXT_NAME"

           # Extract API extension definitions
           grep "^[^#]*\.permissions=" "$TEMP_DIR/ext/page.properties" | while read line; do
               API_NAME=$(echo "$line" | cut -d. -f1)
               PERMISSIONS=$(echo "$line" | cut -d= -f2 | tr ',' '\n' | tr -d ' ')

               echo "[INFO]     - $API_NAME: $(echo $PERMISSIONS | tr '\n' ', ')"

               # Record permissions for validation
               for PERM in $PERMISSIONS; do
                   record_permission "$PERM" "$EXT_NAME" "$API_NAME" "maven"
               done
           done
       fi

       rm -rf "$TEMP_DIR/ext"
   done

   rm -rf "$TEMP_DIR"
   ```

4. Build list of all permissions found in Maven dependencies

## Example Extensions Found

Common Bonita Maven dependencies that may include REST API extensions:

- `reportingRestAPI-{version}.zip` (from bonita-reporting-application)
- Custom organization extensions
- Third-party REST APIs

## Output

```
[INFO] Checking Maven dependency ZIPs...
[INFO]   Found application ZIP: app/target/poc-cnaf-rh2026-1.1.0-presales.zip
[INFO]   Found REST API extension: reportingRestAPI-2.0.0
[INFO]     - getProcessesAPI: process_visualization
[INFO]     - getTaskGraphAPI: task_visualization
[INFO]     - exportTasksAPI: task_visualization
[INFO]     - getCaseAverageAPI: process_visualization, case_visualization, task_visualization, flownode_visualization
[INFO]     - exportCasesAPI: process_visualization, case_visualization, task_visualization, flownode_visualization
[INFO]
[INFO]   Permissions found in Maven dependencies: 4 unique
```

## Data Structure

For each permission found, record:
```json
{
  "permission": "process_visualization",
  "source": "maven",
  "extension": "reportingRestAPI-2.0.0",
  "endpoints": ["getProcessesAPI", "getCaseAverageAPI", "exportCasesAPI"]
}
```

## Error Handling

- If application ZIP not found: Warn and skip Maven scanning
- If ZIP extraction fails: Log error and skip that ZIP
- If page.properties not found in ZIP: Skip silently (not a REST API extension)
- If page.properties has no permissions: Log warning

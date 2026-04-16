# Step 3: Add Maven Dependency

Add the selected connector's Maven dependency to the application pom.xml.

## Input

- Selected connector metadata (groupId, artifactId, version)
- File: `app/pom.xml`
- Dry-run mode flag (if enabled)

## Processing

1. **Read application pom.xml**:
   ```bash
   cat app/pom.xml
   ```
   - Validate file exists
   - Validate XML is well-formed

2. **Check for existing dependency**:
   - Search for `<artifactId>{connector-artifactId}</artifactId>`
   - If found:
     - Extract current version
     - Compare with connector version
     - Determine action:
       - Same version → Skip addition, inform user
       - Different version → Ask user: update, skip, or keep both

3. **Locate dependencies section**:
   - Find `<dependencies>` tag
   - If not found, create one after `<properties>` section

4. **Format new dependency**:
   ```xml
   <!-- {Connector Display Name} {version} -->
   <dependency>
       <groupId>{groupId}</groupId>
       <artifactId>{artifactId}</artifactId>
       <version>{version}</version>
   </dependency>
   ```

5. **Insert dependency**:
   - Add at the end of `<dependencies>` section (before closing `</dependencies>`)
   - Preserve indentation (4 spaces per level)
   - Add blank line before and after for readability
   - Add comment above dependency

6. **Validate modified pom.xml**:
   - Check XML is still well-formed
   - Verify dependency was added correctly
   - If validation fails, rollback changes

7. **Write updated pom.xml**:
   - If dry-run mode: Show diff but don't write
   - Otherwise: Write file with preserved formatting

8. **Backup original** (optional safety):
   - Create `app/pom.xml.backup` before writing

## Output

- Updated `app/pom.xml` with new dependency
- Confirmation message with dependency details

## Example Output

### New Dependency Added

```
[INFO] Step 3: Adding Maven dependency...
[INFO] Reading app/pom.xml...
[OK]   File is valid XML

[INFO] Checking for existing dependency...
[INFO] Dependency not found, will add new entry

[INFO] Adding dependency:
       <dependency>
           <groupId>org.bonitasoft.connectors</groupId>
           <artifactId>bonita-connector-email</artifactId>
           <version>1.3.0</version>
       </dependency>

[OK]   Dependency added successfully to app/pom.xml
[INFO] Backup created: app/pom.xml.backup
```

### Dependency Already Exists

```
[INFO] Step 3: Checking Maven dependency...
[INFO] Reading app/pom.xml...

[WARN] Dependency already exists:
       org.bonitasoft.connectors:bonita-connector-email:1.3.0

[PROMPT] What would you like to do?
         1. Skip (keep existing dependency)
         2. Update to selected version
         3. Add anyway (duplicate)

[USER] Selected: Skip (keep existing dependency)

[INFO] Skipping dependency addition
[INFO] Moving to next step...
```

### Version Conflict

```
[INFO] Checking for existing dependency...
[WARN] Found existing dependency with different version:
       Current: org.bonitasoft.connectors:bonita-connector-email:1.2.0
       Selected: org.bonitasoft.connectors:bonita-connector-email:1.3.0

[PROMPT] Would you like to update to version 1.3.0?
         (This will replace the existing dependency)

[USER] Confirmed: Yes, update to 1.3.0

[INFO] Updating dependency version...
[OK]   Dependency updated: 1.2.0 → 1.3.0
```

### Dry-Run Mode

```
[DRY-RUN] Would add dependency to app/pom.xml:

--- Current pom.xml (excerpt) ---
    <dependencies>
        <dependency>
            <groupId>org.bonitasoft.engine</groupId>
            <artifactId>bonita-client</artifactId>
        </dependency>
    </dependencies>

+++ Modified pom.xml (excerpt) +++
    <dependencies>
        <dependency>
            <groupId>org.bonitasoft.engine</groupId>
            <artifactId>bonita-client</artifactId>
        </dependency>

        <!-- Email Connector 1.3.0 -->
        <dependency>
            <groupId>org.bonitasoft.connectors</groupId>
            <artifactId>bonita-connector-email</artifactId>
            <version>1.3.0</version>
        </dependency>
    </dependencies>

[DRY-RUN] No changes written (dry-run mode)
```

## XML Formatting Rules

1. **Indentation**: Use 4 spaces per level (match existing pom.xml style)
2. **Blank lines**: Add one blank line before dependency comment
3. **Comments**: Add descriptive comment above each dependency
4. **Order**: Add new dependencies at the end of the section

Example formatting:
```xml
<dependencies>
    <!-- Existing dependencies -->
    <dependency>
        <groupId>...</groupId>
        <artifactId>...</artifactId>
    </dependency>

    <!-- Email Connector 1.3.0 - Added by bonita-add-connector -->
    <dependency>
        <groupId>org.bonitasoft.connectors</groupId>
        <artifactId>bonita-connector-email</artifactId>
        <version>1.3.0</version>
    </dependency>
</dependencies>
```

## Error Handling

### pom.xml Not Found

```
[ERROR] Application pom.xml not found at: app/pom.xml
[ERROR] Please ensure you are in the project root directory

Project structure should be:
  project-root/
  ├── app/
  │   └── pom.xml
  └── ...
```

### Invalid XML

```
[ERROR] app/pom.xml is not valid XML
[ERROR] Cannot safely add dependency

Please fix XML syntax errors first:
  Line 45: Unclosed tag <dependency>
```

### Validation Failed After Modification

```
[ERROR] Modified pom.xml failed validation
[ERROR] Rolling back changes...
[OK]   Original pom.xml restored from backup

This is a bug in the skill. Please report this issue.
```

## Rollback Strategy

If any error occurs after modification:
1. Restore from `app/pom.xml.backup`
2. Log error details
3. Exit with error status

## Validation Checks

1. **XML well-formed**: Parse with XML parser
2. **Dependency format**: Verify all required fields (groupId, artifactId, version)
3. **No duplicates**: Check artifactId doesn't appear twice
4. **Valid Maven identifiers**: Check format of groupId and artifactId

## Tips

- Always create backup before modification
- Preserve existing formatting and comments
- Add meaningful comments for traceability
- Use Edit tool for precise XML modifications
- Test modified pom.xml with `./mvnw validate`

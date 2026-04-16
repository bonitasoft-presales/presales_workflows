# Step 1: Scan Connector Documentation

Scan the documentation directory to identify available Bonita connectors.

## Input

- Directory: `docs/out/` (and subdirectories)
- Expected format: Markdown files containing connector information

## Processing

1. **Locate connector documentation files**:
   ```bash
   find docs/out/ -name "*.md" -type f
   ```

2. **For each documentation file**:
   - Read the file content
   - Extract connector metadata:
     - **Name**: Look for main heading (# Connector Name)
     - **Description**: Extract first paragraph after heading
     - **Maven coordinates**: Find XML dependency block
       ```xml
       <dependency>
           <groupId>...</groupId>
           <artifactId>...</artifactId>
           <version>...</version>
       </dependency>
       ```
     - **Version**: Extract from dependency or heading
     - **Capabilities**: Extract from "Features" or "Capabilities" section

3. **Parse Maven coordinates**:
   - Extract `groupId`, `artifactId`, `version` from XML
   - Validate format (not empty, valid Maven identifiers)
   - Store in structured format

4. **Build connector catalog**:
   ```json
   [
     {
       "name": "email-connector",
       "displayName": "Email Connector",
       "description": "Send emails via SMTP protocol",
       "groupId": "org.bonitasoft.connectors",
       "artifactId": "bonita-connector-email",
       "version": "1.3.0",
       "docFile": "docs/out/connectors/email-connector.md"
     },
     ...
   ]
   ```

5. **Sort connectors alphabetically** by display name

## Output

- List of available connectors with metadata
- Count of connectors found
- Any warnings for malformed documentation

## Example Output

```
[INFO] Scanning connector documentation in docs/out/...
[INFO] Found 5 connector documentation files:
       - docs/out/connectors/email-connector.md
       - docs/out/connectors/database-connector.md
       - docs/out/connectors/rest-connector.md
       - docs/out/connectors/sap-connector.md
       - docs/out/connectors/salesforce-connector.md

[INFO] Parsed connectors:
       1. Database Connector (v2.1.0) - Execute SQL queries
       2. Email Connector (v1.3.0) - Send emails via SMTP
       3. REST Connector (v1.5.0) - Call REST APIs
       4. Salesforce Connector (v2.2.0) - Connect to Salesforce
       5. SAP Connector (v3.0.0) - Integrate with SAP systems
```

## Error Handling

### No Documentation Found

If `docs/out/` is empty or doesn't exist:
```
[ERROR] No connector documentation found in docs/out/
[INFO]  Expected structure:
        docs/out/connectors/
        ├── connector1.md
        ├── connector2.md
        └── ...

[INFO]  Please add connector documentation files before running this skill.
```

### Malformed Documentation

If a file can't be parsed:
```
[WARN] Could not parse connector documentation: docs/out/connectors/broken.md
[WARN] Missing required field: Maven dependency block
[INFO] Skipping this connector and continuing...
```

### No Valid Connectors

If no valid connectors are found:
```
[ERROR] No valid connectors found in documentation
[ERROR] All documentation files are missing required information

[INFO]  Each connector doc must include:
        - Connector name (# heading)
        - Description
        - Maven dependency with groupId, artifactId, version
```

## Validation Rules

1. **Connector name** must be present in heading
2. **Maven coordinates** must all be present (groupId, artifactId, version)
3. **Version** must follow semantic versioning (X.Y.Z)
4. **groupId** and **artifactId** must be valid Maven identifiers
5. **Description** should be at least 10 characters

## Tips

- Documentation files can be in any subdirectory of `docs/out/`
- Connector name is case-insensitive for matching
- If multiple versions are found, use the latest version
- Custom connectors (non-Bonitasoft) are also supported

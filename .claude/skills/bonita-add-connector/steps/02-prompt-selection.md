# Step 2: Prompt User Selection

Present available connectors to the user and let them choose which one to add.

## Input

- List of available connectors from Step 1
- User preferences from command-line flags (if `--connector` specified)

## Processing

1. **Check for pre-selection**:
   - If `--connector <name>` flag was provided:
     - Find matching connector in list
     - Validate it exists
     - Skip prompt and use this connector
   - Otherwise, continue to interactive prompt

2. **Prepare connector options** for AskUserQuestion:
   - Format each connector as an option:
     ```
     label: "Email Connector (v1.3.0)"
     description: "Send emails via SMTP protocol. Use for notifications, alerts, and automated communications."
     ```
   - Include version in label for clarity
   - Limit description to 100 characters

3. **Use AskUserQuestion tool** to prompt selection:
   ```json
   {
     "questions": [{
       "question": "Which connector would you like to add to your project?",
       "header": "Connector",
       "options": [
         {
           "label": "Email Connector (v1.3.0)",
           "description": "Send emails via SMTP - notifications and alerts"
         },
         {
           "label": "Database Connector (v2.1.0)",
           "description": "Execute SQL queries - data integration"
         },
         ...
       ],
       "multiSelect": false
     }]
   }
   ```

4. **Process user selection**:
   - Get selected connector name
   - Retrieve full connector metadata
   - Validate selection is valid

5. **Confirm selection** (if not in `--auto` mode):
   - Display connector details:
     - Name and version
     - Maven coordinates
     - Brief description
   - Ask for confirmation to proceed

## Output

- Selected connector metadata
- User confirmation to proceed

## Example Output

```
[PROMPT] Which connector would you like to add to your project?

Available connectors:
  1. Database Connector (v2.1.0)
     Execute SQL queries - data integration

  2. Email Connector (v1.3.0)
     Send emails via SMTP - notifications and alerts

  3. REST Connector (v1.5.0)
     Call REST APIs - external integrations

  4. Salesforce Connector (v2.2.0)
     Connect to Salesforce - CRM integration

  5. SAP Connector (v3.0.0)
     Integrate with SAP systems - ERP integration

[USER] Selected: Email Connector (v1.3.0)

[INFO] Selected connector details:
       Name: Email Connector
       Version: 1.3.0
       Maven: org.bonitasoft.connectors:bonita-connector-email:1.3.0
       Description: Send emails via SMTP protocol

[INFO] Proceeding with connector addition...
```

## Command-Line Pre-Selection

When `--connector` flag is provided:

```bash
/bonita-add-connector --connector email-connector
```

Output:
```
[INFO] Connector pre-selected: email-connector
[INFO] Finding connector in catalog...
[OK]   Found: Email Connector (v1.3.0)
       org.bonitasoft.connectors:bonita-connector-email:1.3.0
[INFO] Proceeding with connector addition...
```

## Error Handling

### Invalid Pre-Selection

If `--connector` specifies unknown connector:
```
[ERROR] Connector not found: unknown-connector
[INFO]  Available connectors:
        - email-connector
        - database-connector
        - rest-connector
        - sap-connector
        - salesforce-connector

[ERROR] Please specify a valid connector name or run without --connector flag for interactive selection.
```

### User Cancels Selection

If user cancels the prompt:
```
[INFO] Connector selection cancelled by user
[INFO] No changes made to project
```

### No Connectors Available

If connector list is empty:
```
[ERROR] No connectors available to select
[ERROR] Please ensure connector documentation exists in docs/out/

Skill execution stopped.
```

## Validation Rules

1. **Connector name must exist** in the scanned catalog
2. **Selection cannot be empty** (user must choose)
3. **Pre-selection must match** a known connector (case-insensitive)

## Tips

- Connector names in `--connector` flag are case-insensitive
- Partial matching is supported (e.g., "email" matches "email-connector")
- If multiple matches, show disambiguation prompt
- Most recently used connector could be suggested first (future enhancement)

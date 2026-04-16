---
name: bonita-add-connector
description: Add a Bonita connector with automatic Maven dependency management and demo process generation. Use when the user wants to add, integrate, or configure a Bonita connector in the project.
disable-model-invocation: true
argument-hint: "[--connector <name>] [--process <name>] [--dry-run] [--no-demo]"
allowed-tools: Read, Write, Bash, Glob, Grep
---

# bonita-add-connector

Add a Bonita connector to your project with automatic dependency management and demo process generation.

This skill streamlines the process of adding connectors to Bonita projects by:
- Identifying available connectors from documentation
- Managing Maven dependencies automatically
- Creating a demo process to showcase connector usage

## Usage

```bash
# Add a connector interactively
/bonita-add-connector

# Add a specific connector directly
/bonita-add-connector --connector email-connector

# Add connector to a specific process
/bonita-add-connector --process MyProcess

# Dry-run mode (show what would be done without making changes)
/bonita-add-connector --dry-run
```

## Parameters

- `--connector <name>` - Skip selection prompt and add the specified connector directly
- `--process <name>` - Target process name for the demo (default: auto-generated)
- `--dry-run` - Show what would be done without making changes
- `--no-demo` - Skip demo process creation, only add dependency

## Prerequisites

- Project follows standard Bonita structure
- Connector documentation available in `docs/out/` directory
- Application pom.xml exists at `app/pom.xml`
- Write access to `app/diagrams/` directory

## What This Skill Does

This skill automates the connector integration workflow:

1. **Discovers Available Connectors**: Scans connector documentation in `docs/out/`
2. **Interactive Selection**: Prompts user to choose from available connectors
3. **Dependency Management**: Adds Maven dependency to `app/pom.xml`
4. **Demo Generation**: Creates a sample process diagram demonstrating connector usage

## Global Directives

**IMPORTANT**: Follow these rules when adding connectors:

1. **Always validate connector availability** before attempting to add it
2. **Check for duplicate dependencies** in pom.xml before adding
3. **Use semantic versioning** for connector versions
4. **Generate meaningful demo processes** that showcase key connector features
5. **Preserve existing pom.xml formatting** and structure
6. **Follow Bonita naming conventions** for process diagrams
7. **Add appropriate comments** to generated code and configuration

## Execution Steps

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--connector`, `--dry-run`) before starting.

### Step 1: Scan Connector Documentation
[Read detailed instructions](steps/01-scan-docs.md)
- Scan `docs/out/` directory for connector documentation
- Parse connector metadata (name, version, groupId, artifactId)
- Extract connector capabilities and requirements
- Build list of available connectors with descriptions

### Step 2: Prompt User Selection
[Read detailed instructions](steps/02-prompt-selection.md)
- Display list of available connectors with descriptions
- Use AskUserQuestion to present connector options
- Allow user to select desired connector
- Validate selection

### Step 3: Add Maven Dependency
[Read detailed instructions](steps/03-add-dependency.md)
- Read `app/pom.xml`
- Check if connector dependency already exists
- Determine appropriate dependency scope (compile/runtime)
- Add dependency to dependencies section
- Preserve formatting and comments
- Validate pom.xml syntax after modification

### Step 4: Generate Demo Process
[Read detailed instructions](steps/04-generate-demo.md)
- Create a new process diagram in `app/diagrams/`
- Name format: `_demo{ConnectorName}-1.0.proc`
- Include connector configuration example
- Add service task demonstrating connector usage
- Configure connector inputs/outputs
- Add form mapping (type="NONE" for demo processes)
- Generate valid BPMN XML structure

### Step 5: Validate and Report
[Read detailed instructions](steps/05-validate-report.md)
- Verify pom.xml is valid XML
- Verify process diagram is valid
- Build project to confirm no errors
- Generate summary report with:
  - Connector added
  - Dependency details (groupId:artifactId:version)
  - Demo process location
  - Next steps for user

## Connector Documentation Format

The skill expects connector documentation in `docs/out/` with this structure:

```
docs/out/
├── connectors/
│   ├── email-connector.md
│   ├── database-connector.md
│   └── rest-connector.md
```

Each connector documentation file should contain:
- Connector name and description
- Maven coordinates (groupId, artifactId, version)
- Configuration parameters
- Usage examples

Example connector doc format:

```markdown
# Email Connector

Send emails via SMTP protocol.

## Maven Dependency

```xml
<dependency>
    <groupId>org.bonitasoft.connectors</groupId>
    <artifactId>bonita-connector-email</artifactId>
    <version>1.3.0</version>
</dependency>
```

## Parameters
- smtpHost: SMTP server hostname
- smtpPort: SMTP server port
- ...
```

## Output Examples

### Successful Addition

```
============================================
Bonita Connector Addition
============================================

[INFO] Step 1: Scanning connector documentation...
[INFO]   Found 5 connectors in docs/out/connectors/

Available connectors:
  1. email-connector (v1.3.0) - Send emails via SMTP
  2. database-connector (v2.1.0) - Execute SQL queries
  3. rest-connector (v1.5.0) - Call REST APIs
  4. sap-connector (v3.0.0) - Integrate with SAP systems
  5. salesforce-connector (v2.2.0) - Connect to Salesforce

[PROMPT] Which connector would you like to add?

[USER] Selected: email-connector

[INFO] Step 2: Adding Maven dependency...
[INFO]   Reading app/pom.xml...
[INFO]   Checking for existing dependency...
[INFO]   Adding dependency: org.bonitasoft.connectors:bonita-connector-email:1.3.0
[OK]    Dependency added successfully

[INFO] Step 3: Generating demo process...
[INFO]   Creating diagram: app/diagrams/_demoEmailConnector-1.0.proc
[INFO]   Configuring service task with connector...
[INFO]   Adding connector parameters...
[OK]    Demo process created successfully

========================================
Connector added successfully ✓
========================================

Summary:
  Connector: email-connector v1.3.0
  Dependency: org.bonitasoft.connectors:bonita-connector-email:1.3.0
  Demo process: app/diagrams/_demoEmailConnector-1.0.proc

Next steps:
  1. Review the generated demo process
  2. Rebuild the project: ./mvnw clean package
  3. Deploy to test the connector functionality
  4. Customize the connector configuration for your use case

Files modified:
  - app/pom.xml (dependency added)
  - app/diagrams/_demoEmailConnector-1.0.proc (created)
```

### Connector Already Exists

```
============================================
Bonita Connector Addition
============================================

[INFO] Step 1: Scanning connector documentation...
[INFO]   Found 5 connectors

[USER] Selected: email-connector

[INFO] Step 2: Checking Maven dependency...
[WARN]   Dependency already exists in pom.xml
          org.bonitasoft.connectors:bonita-connector-email:1.3.0

[PROMPT] The connector is already in your project.
         Would you like to:
         1. Skip (do nothing)
         2. Create demo process only
         3. Update to latest version

[USER] Selected: Create demo process only

[INFO] Step 3: Generating demo process...
[OK]    Demo process created: app/diagrams/_demoEmailConnector-1.0.proc

========================================
Demo process created ✓
========================================

No changes made to pom.xml (dependency already exists).
Demo process available at: app/diagrams/_demoEmailConnector-1.0.proc
```

### Dry-Run Mode

```
============================================
Bonita Connector Addition (DRY-RUN MODE)
============================================

[INFO] No changes will be made to your project

[USER] Selected: database-connector

[DRY-RUN] Would add Maven dependency:
  <dependency>
      <groupId>org.bonitasoft.connectors</groupId>
      <artifactId>bonita-connector-database</artifactId>
      <version>2.1.0</version>
  </dependency>

[DRY-RUN] Would create demo process:
  File: app/diagrams/_demoDatabaseConnector-1.0.proc
  Process name: _demoDatabaseConnector
  Service task: "Execute Query"
  Connector: bonita-connector-database

========================================
Dry-run completed (no changes made)
========================================

To apply these changes, run without --dry-run:
  /bonita-add-connector --connector database-connector
```

## Demo Process Structure

The generated demo process follows this structure:

```xml
<process:MainProcess name="_demo{ConnectorName}">
  <elements type="Pool" name="_demo{ConnectorName}">
    <elements type="Lane" name="Employee lane">
      <elements type="StartEvent" name="Start"/>
      <elements type="ServiceTask" name="Use {ConnectorName}">
        <connectors definitionId="{connector-id}">
          <!-- Connector configuration here -->
        </connectors>
      </elements>
      <elements type="EndEvent" name="End"/>
    </elements>
    <formMapping type="NONE"/>
    <actors name="Employee actor" initiator="true"/>
    <configurations name="Local">
      <actorMappings>
        <actorMapping name="Employee actor">
          <roles><role>member</role></roles>
        </actorMapping>
      </actorMappings>
    </configurations>
    <contract/>
  </elements>
</process:MainProcess>
```

## Maven Dependency Format

Dependencies are added to `app/pom.xml` in the `<dependencies>` section:

```xml
<dependencies>
    <!-- Existing dependencies -->

    <!-- Added by bonita-add-connector -->
    <dependency>
        <groupId>org.bonitasoft.connectors</groupId>
        <artifactId>bonita-connector-{name}</artifactId>
        <version>{version}</version>
    </dependency>
</dependencies>
```

## Error Handling

### Missing Documentation

If connector documentation is not found:
```
[ERROR] No connector documentation found in docs/out/
[ERROR] Please ensure connector documentation is available

To fix:
  1. Add connector documentation to docs/out/connectors/
  2. Follow the connector documentation format
  3. Run the skill again
```

### Invalid pom.xml

If pom.xml has syntax errors after modification:
```
[ERROR] Generated pom.xml is not valid XML
[ERROR] Changes have been rolled back

The original pom.xml has been restored.
Please report this issue with your connector selection.
```

### Build Failure

If project doesn't build after adding connector:
```
[WARN] Project build failed after adding connector

Possible causes:
  - Connector dependency not available in Maven repository
  - Version conflict with existing dependencies
  - Missing transitive dependencies

Troubleshooting:
  1. Check Maven repository availability
  2. Review dependency tree: ./mvnw dependency:tree
  3. Try a different connector version
```

## Common Scenarios

### Scenario 1: Add Email Connector for Notifications

```bash
# Add email connector
/bonita-add-connector

# Select "email-connector" from prompt
# Review generated demo process
# Customize for your notification requirements
```

### Scenario 2: Quick Add Without Demo

```bash
# Add REST connector without demo process
/bonita-add-connector --connector rest-connector --no-demo
```

### Scenario 3: Preview Changes First

```bash
# See what would be added
/bonita-add-connector --dry-run

# If looks good, apply changes
/bonita-add-connector --connector database-connector
```

## Integration with Other Skills

This skill works well with:

- `/bonita-validate-artifacts` - Validate generated demo process
- `/bonita-deploy-local` - Deploy and test the connector
- `/bonita-generate-process` - Generate production processes using the connector

## Notes

- Demo processes are prefixed with `_demo` to distinguish them from production processes
- The skill preserves all existing pom.xml content and formatting
- Connector versions are taken from documentation (not automatically updated)
- Demo processes have no forms (type="NONE") for simplicity
- The skill does not configure connector parameters (user must do this)
- Existing demo processes are not overwritten (user must delete manually)

## See Also

- Bonita Connector Documentation: https://documentation.bonitasoft.com/bonita/latest/connectors
- Maven Dependency Management: `pom.xml` structure
- Process Diagram Format: BPMN 2.0 XML specification
- `/bonita-validate-artifacts` - Validate generated artifacts

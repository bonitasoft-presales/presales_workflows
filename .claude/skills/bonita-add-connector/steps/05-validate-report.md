# Step 5: Validate and Report

Validate all changes and generate a comprehensive report for the user.

## Input

- Modified files from previous steps:
  - `app/pom.xml` (if dependency was added)
  - `app/diagrams/{processName}-1.0.proc` (if demo was created)
- Selected connector metadata
- Execution flags (dry-run, no-demo, etc.)

## Processing

1. **Validate pom.xml** (if modified):
   - Parse XML to ensure well-formed
   - Verify dependency exists in `<dependencies>` section
   - Check Maven identifiers are valid format
   - Optional: Run `./mvnw validate` to ensure Maven accepts it

2. **Validate demo process** (if created):
   - Parse XML to ensure well-formed
   - Verify required BPMN elements exist
   - Check all xmi:id references are valid
   - Verify connector configuration is present
   - Optional: Validate against Bonita XSD schema

3. **Build verification** (optional):
   - Run `./mvnw clean package -DskipTests`
   - Ensure project still compiles
   - Check for dependency conflicts
   - Report any build warnings or errors

4. **Collect changes summary**:
   - List all modified files
   - Extract key changes:
     - Dependency added (groupId:artifactId:version)
     - Demo process created (name, location)
   - Note any warnings or issues encountered

5. **Generate user report**:
   - Summary section with key information
   - Files modified section
   - Next steps for the user
   - Troubleshooting tips if needed

6. **Exit with appropriate status**:
   - 0 = Success (all validations passed)
   - 1 = Partial success (warnings)
   - 2 = Failure (errors occurred)

## Output

- Comprehensive report to user
- Exit status code
- Optional: Summary saved to log file

## Example Output

### Complete Success

```
========================================
Connector Added Successfully ✓
========================================

Summary:
  Connector: Email Connector v1.3.0
  Maven: org.bonitasoft.connectors:bonita-connector-email:1.3.0
  Demo: _demoEmailConnector-1.0

Files Modified:
  ✓ app/pom.xml (dependency added)
  ✓ app/diagrams/_demoEmailConnector-1.0.proc (created)

Validation:
  ✓ pom.xml is valid XML
  ✓ Process diagram is valid BPMN
  ✓ Project builds successfully

Next Steps:
  1. Review the generated demo process:
     - Open in Bonita Studio: app/diagrams/_demoEmailConnector-1.0.proc
     - Customize connector parameters for your use case

  2. Rebuild the project:
     ./mvnw clean package

  3. Deploy to test the connector:
     /bonita-deploy-local

  4. Create your production process:
     - Copy configuration from demo process
     - Integrate connector into your workflow
     - Test with real data

Documentation:
  Connector docs: docs/out/connectors/email-connector.md
  Bonita docs: https://documentation.bonitasoft.com/bonita/latest/connectors

Need help?
  - Validate artifacts: /bonita-validate-artifacts
  - Deploy locally: /bonita-deploy-local
  - View logs: app/target/surefire-reports/
```

### Partial Success (Dependency Only)

```
========================================
Connector Added (Partial) ⚠
========================================

Summary:
  Connector: Email Connector v1.3.0
  Maven: org.bonitasoft.connectors:bonita-connector-email:1.3.0
  Demo: Skipped (--no-demo flag)

Files Modified:
  ✓ app/pom.xml (dependency added)
  - app/diagrams/ (no demo created)

Validation:
  ✓ pom.xml is valid XML
  ✓ Project builds successfully

Next Steps:
  1. Rebuild the project:
     ./mvnw clean package

  2. Create a process using this connector:
     - Add service task to your process
     - Configure connector: bonita-connector-email
     - Set connector parameters

  3. Or generate a demo process:
     /bonita-add-connector --connector email-connector

Note: No demo process was created (--no-demo flag).
      Run without --no-demo to generate a demo process.
```

### With Warnings

```
========================================
Connector Added with Warnings ⚠
========================================

Summary:
  Connector: Email Connector v1.3.0
  Maven: org.bonitasoft.connectors:bonita-connector-email:1.3.0
  Demo: _demoEmailConnector-1.0

Files Modified:
  ✓ app/pom.xml (dependency added)
  ✓ app/diagrams/_demoEmailConnector-1.0.proc (created)

Validation:
  ✓ pom.xml is valid XML
  ✓ Process diagram is valid BPMN
  ⚠ Build completed with warnings

Warnings:
  [WARNING] Dependency 'bonita-connector-email' may conflict with existing 'mail' dependency
  [WARNING] Consider excluding transitive dependency: javax.mail:mail

Recommendations:
  1. Review dependency tree:
     ./mvnw dependency:tree

  2. If issues occur, add exclusion to pom.xml:
     <dependency>
         <groupId>org.bonitasoft.connectors</groupId>
         <artifactId>bonita-connector-email</artifactId>
         <version>1.3.0</version>
         <exclusions>
             <exclusion>
                 <groupId>javax.mail</groupId>
                 <artifactId>mail</artifactId>
             </exclusion>
         </exclusions>
     </dependency>

Next Steps:
  1. Review warnings above
  2. Test connector functionality
  3. Adjust configuration if needed

The connector was added successfully despite warnings.
Monitor for runtime issues during testing.
```

### Build Failure

```
========================================
Connector Addition Failed ✗
========================================

Summary:
  Connector: Email Connector v1.3.0
  Status: Build verification failed

Files Modified:
  ✓ app/pom.xml (dependency added)
  ✓ app/diagrams/_demoEmailConnector-1.0.proc (created)
  ⚠ Changes were not rolled back (see troubleshooting)

Validation:
  ✓ pom.xml is valid XML
  ✓ Process diagram is valid BPMN
  ✗ Build failed with errors

Error Details:
  [ERROR] Failed to execute goal on project: Could not resolve dependencies
  [ERROR] The following artifacts could not be resolved:
          org.bonitasoft.connectors:bonita-connector-email:jar:1.3.0

Possible Causes:
  1. Connector version not available in Maven repository
  2. Maven repository not accessible
  3. Incorrect connector coordinates in documentation

Troubleshooting:
  1. Check connector availability:
     Search: https://search.maven.org/search?q=bonita-connector-email

  2. Verify Maven settings:
     Check: ~/.m2/settings.xml

  3. Try different version:
     Update docs/out/connectors/email-connector.md with available version
     Run /bonita-add-connector again

  4. Manual rollback if needed:
     Restore: app/pom.xml.backup → app/pom.xml
     Delete: app/diagrams/_demoEmailConnector-1.0.proc

Need Help?
  - Contact Bonitasoft support
  - Check connector documentation
  - Verify Maven repository configuration
```

### Dry-Run Summary

```
========================================
Dry-Run Summary (No Changes Made)
========================================

Selected Connector:
  Name: Email Connector v1.3.0
  Maven: org.bonitasoft.connectors:bonita-connector-email:1.3.0

Changes That Would Be Made:

  1. Add dependency to app/pom.xml:
     <dependency>
         <groupId>org.bonitasoft.connectors</groupId>
         <artifactId>bonita-connector-email</artifactId>
         <version>1.3.0</version>
     </dependency>

  2. Create demo process:
     File: app/diagrams/_demoEmailConnector-1.0.proc
     Process: _demoEmailConnector (version 1.0)
     Service Task: "Send Email"
     Connector: bonita-connector-email

Validation (Preview):
  ✓ Connector exists in documentation
  ✓ Maven coordinates are valid
  ✓ Process name is valid
  ✓ No conflicts detected

To Apply These Changes:
  Run without --dry-run flag:
    /bonita-add-connector --connector email-connector

Note: This was a dry-run. No files were modified.
```

## Validation Checklist

- [ ] pom.xml is valid XML
- [ ] Dependency exists in `<dependencies>` section
- [ ] groupId, artifactId, version are all present
- [ ] Demo process is valid XML (if created)
- [ ] All BPMN required elements exist
- [ ] Connector definition is present
- [ ] Project builds without errors
- [ ] No critical warnings

## Report Sections

1. **Header**: Success/Warning/Failure banner
2. **Summary**: Connector details, status
3. **Files Modified**: List with status icons
4. **Validation Results**: Checks performed with results
5. **Warnings/Errors**: Any issues encountered
6. **Next Steps**: Actionable items for user
7. **Documentation Links**: Helpful resources
8. **Troubleshooting**: If problems occurred

## Status Icons

- ✓ Success
- ⚠ Warning
- ✗ Error
- - Skipped/Not applicable

## Error Handling

### Build Timeout

If build takes too long:
```
[WARN] Build validation timed out after 2 minutes
[INFO] Files were modified but build verification is incomplete

Recommend:
  Run manual build verification:
    ./mvnw clean package
```

### Validation Skipped

If validation cannot be performed:
```
[INFO] Build validation skipped (Maven not available)
[INFO] Please manually verify:
      ./mvnw clean package
```

## Tips

- Always run build verification when possible
- Include rollback instructions if errors occur
- Provide links to relevant documentation
- Suggest next skills user might need
- Keep report concise but informative
- Use clear status indicators (✓ ⚠ ✗)

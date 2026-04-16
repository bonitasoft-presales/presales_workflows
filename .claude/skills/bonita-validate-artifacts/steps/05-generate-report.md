# Step 5: Generate Validation Report

Generate a comprehensive validation report summarizing the results from all validation steps.

## Input

- Validation results from Steps 1-4 (collected during execution)
- File statistics for each validated artifact

## Process

1. Collect all validation results
2. Calculate file statistics (size, line count) for each file
3. Generate formatted report
4. Determine overall status
5. Exit with appropriate code

## Report Structure

```
Bonita Artifacts Validation Report
===================================

Directory: docs/artifacts/

BDM (Business Data Model)
-------------------------
✓ bom.xml (2,345 bytes, 67 lines)

Organization
------------
✓ organization.xml (3,456 bytes, 98 lines)

Process Diagrams
----------------
✓ Validation_Demande_Recrutement-1.0.proc (8,912 bytes, 287 lines)
✓ Traitement_Candidature-1.0.proc (7,234 bytes, 245 lines)

Profiles
--------
✓ profile.xml (1,234 bytes, 42 lines)

Summary
=======
Total files validated: 5
Successful: 5 ✓
Failed: 0
Not found: 0

Status: All artifacts valid ✓
```

## Report Sections

### 1. Header
- Title: "Bonita Artifacts Validation Report"
- Separator line
- Target directory path

### 2. BDM Section
- Section title: "BDM (Business Data Model)"
- Status indicator: ✓ (success), ✗ (failure), - (not found)
- Filename: bom.xml
- File statistics in parentheses
- Error details if failed (indented)

### 3. Organization Section
- Section title: "Organization"
- Status, filename, statistics
- Error details if failed

### 4. Process Diagrams Section
- Section title: "Process Diagrams"
- One line per .proc file
- Status, filename, statistics per file
- Error details if any failed
- Message if no process files found

### 5. Profiles Section
- Section title: "Profiles"
- Status, filename, statistics
- Error details if failed

### 6. Summary
- Separator line
- Section title: "Summary"
- Total files validated count
- Successful validations count with ✓
- Failed validations count with ✗
- Not found count (optional artifacts)
- Blank line
- Overall status message

## Status Indicators

- `✓` - Validation passed
- `✗` - Validation failed
- `-` - File not found (optional artifact)

## Overall Status Messages

### All Valid
```
Status: All artifacts valid ✓
```

### Some Failed
```
Status: Validation failed - X error(s) found ✗
```

### No Artifacts Found
```
Status: No artifacts found in directory
```

## File Statistics Format

Display file information in format: `(size bytes, lines lines)`

Examples:
- `(1,234 bytes, 42 lines)`
- `(12,345 bytes, 387 lines)`

Use comma separators for thousands in byte counts.

## Error Details Format

When a file fails validation, display indented error details:

```
✗ bom.xml (2,345 bytes, 67 lines)
  Error: Element 'field', attribute 'type': 'VARCHAR' is not valid
  Line 15: Expected one of: STRING, TEXT, INTEGER, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME
```

## Exit Codes

Determine exit code based on validation results:

- **Exit 0** - All found files validated successfully (missing optional files OK)
- **Exit 1** - One or more files failed validation

## Implementation Notes

### Getting File Statistics

Use standard tools to gather statistics:

```bash
# File size in bytes
stat -f%z filename  # macOS
stat -c%s filename  # Linux

# Line count
wc -l < filename
```

Or use a simple approach:
```bash
# Combined stats
ls -l filename | awk '{print $5}'  # size
wc -l < filename                     # lines
```

### Formatting Numbers

Add comma separators for large numbers:
```bash
# Example: 12345 -> 12,345
printf "%'d" 12345
```

### Collecting Validation Results

Store results in a structured format during steps 1-4:

```bash
# Example structure
declare -A validation_results
validation_results["bom.xml"]="PASS"
validation_results["organization.xml"]="PASS"
validation_results["ProcessName-1.0.proc"]="FAIL|Error message here"
validation_results["profile.xml"]="NOT_FOUND"
```

## Color Coding (Optional)

If terminal supports colors, enhance visibility:
- ✓ in green
- ✗ in red
- - in yellow
- Error details in red

Check terminal support:
```bash
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  NC='\033[0m' # No Color
else
  GREEN=''
  RED=''
  YELLOW=''
  NC=''
fi
```

## Example Complete Report

```
Bonita Artifacts Validation Report
===================================

Directory: docs/artifacts/

BDM (Business Data Model)
-------------------------
✓ bom.xml (2,345 bytes, 67 lines)

Organization
------------
✓ organization.xml (3,456 bytes, 98 lines)

Process Diagrams
----------------
✓ Validation_Demande_Recrutement-1.0.proc (8,912 bytes, 287 lines)
✗ Traitement_Candidature-1.0.proc (7,234 bytes, 245 lines)
  Error: Element 'pool', attribute 'bonitaModelVersion': '8' is not valid
  Line 12: Expected value '9' for Bonita 10.x compatibility

Profiles
--------
- profile.xml (not found)

Summary
=======
Total files validated: 3
Successful: 2 ✓
Failed: 1 ✗
Not found: 1

Status: Validation failed - 1 error(s) found ✗
```

## Output Destination

- Print report to standard output (stdout)
- Optionally save to file: `docs/artifacts/validation-report.txt`
- Exit with appropriate code for CI/CD integration

## Next Steps Guidance

Based on overall status, provide guidance:

### If all valid:
```
All artifacts are valid and ready to import into Bonita Studio.
```

### If some failed:
```
Fix the errors above and re-run validation before importing to Bonita Studio.
Common fixes:
- Check XSD schema namespaces
- Verify all cross-references (IDs, names)
- Ensure Bonita 10.x compatibility (model version, types)
```

### If no artifacts found:
```
No artifacts found in directory. Run /bonita-generate first to create artifacts.
```

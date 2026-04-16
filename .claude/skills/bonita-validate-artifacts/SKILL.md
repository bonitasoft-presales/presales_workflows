---
name: bonita-validate-artifacts
description: Validate Bonita artifacts (BOM, Organization, Process, Profile) against XSD schemas. Use when the user wants to validate, check, or verify XML artifacts before importing to Bonita Studio.
argument-hint: "[--directory <path>] [--file <path>]"
allowed-tools: Read, Bash, Glob, Grep
---

Validate Bonita artifacts (BOM, Organization, Process diagrams, Profiles) against their respective XSD schemas using Docker-based xmllint.

This skill ensures that all generated or manually edited XML and .proc files conform to Bonita's schema definitions before import into Bonita Studio.

## Usage

```bash
# Validate all artifacts in default directory
/bonita-validate-artifacts

# Validate artifacts in specific directory
/bonita-validate-artifacts --directory docs/artifacts/

# Validate a single file
/bonita-validate-artifacts --file docs/artifacts/bom.xml
```

## Parameters

- `--directory <path>` - Directory containing artifacts to validate (default: `docs/artifacts/`)
- `--file <path>` - Single file to validate (optional, overrides --directory)

## Prerequisites

- Docker must be available
- XSD schemas must exist in `.claude/xsd/`:
  - `bom.xsd` - BDM schema
  - `organization.xsd` - Organization schema
  - `ProcessDefinition.xsd` - BPMN process schema
  - `profiles.xsd` - Profile schema
- Artifacts to validate in target directory

## Global Directives

**IMPORTANT**: Use Docker for all tooling. This skill uses the `cytopia/xmllint` Docker image for XSD validation:

```bash
docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/docs/artifacts":/artifacts:ro \
  cytopia/xmllint \
  xmllint --schema /xsd/bom.xsd /artifacts/bom.xml --noout
```

## Execution Steps

Follow these steps in order:

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--directory`, `--file`) before starting.

### Step 1: Validate BOM
[Read detailed instructions](steps/01-validate-bom.md)
- Find `bom.xml` in target directory
- Validate against `.claude/xsd/bom.xsd`
- Report success or detailed error

### Step 2: Validate Organization
[Read detailed instructions](steps/02-validate-organization.md)
- Find `organization.xml` in target directory
- Validate against `.claude/xsd/organization.xsd`
- Report success or detailed error

### Step 3: Validate Process Diagrams
[Read detailed instructions](steps/03-validate-process.md)
- Find all `*.proc` files in target directory
- Validate each against `.claude/xsd/ProcessDefinition.xsd`
- Report success or detailed errors for each file

### Step 4: Validate Profiles
[Read detailed instructions](steps/04-validate-profile.md)
- Find `profile.xml` in target directory
- Validate against `.claude/xsd/profiles.xsd`
- Report success or detailed error

### Step 5: Generate Validation Report
[Read detailed instructions](steps/05-generate-report.md)
- Summarize validation results
- List all validated files with status
- Provide file statistics (size, line count)
- Exit with appropriate code (0=success, 1=failure)

## XSD Schema Mappings

| Artifact Type | File Pattern | XSD Schema |
|---------------|--------------|------------|
| BDM | `bom.xml` | `.claude/xsd/bom.xsd` |
| Organization | `organization.xml` | `.claude/xsd/organization.xsd` |
| Process | `*.proc` | `.claude/xsd/ProcessDefinition.xsd` |
| Profile | `profile.xml` | `.claude/xsd/profiles.xsd` |

## Output

The skill generates a validation report showing:
- Total files validated
- Successful validations (✓)
- Failed validations (✗) with error details
- File statistics (size, lines)
- Overall validation status

### Example Output

```
Validation Report
=================

✓ bom.xml (1234 bytes, 45 lines)
✓ organization.xml (2345 bytes, 78 lines)
✓ Validation_Demande_Recrutement-1.0.proc (5678 bytes, 234 lines)
✓ profile.xml (987 bytes, 32 lines)

Total: 4 files validated
Success: 4
Failures: 0

Status: All artifacts valid ✓
```

## Error Handling

When validation fails:
1. Display the full xmllint error message
2. Identify the problematic element and location
3. Provide common error solutions:
   - Wrong namespace URI
   - Missing required elements
   - Invalid attribute values
   - Incorrect element order
4. Exit with code 1

## Common Validation Errors

### BOM Errors
- **Namespace mismatch**: Ensure `xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0"`
- **Invalid field type**: Use only: STRING, TEXT, INTEGER, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME
- **Duplicate query names**: Each query must have unique name
- **COMPOSITION reference**: Use AGGREGATION only (Bonita 10.x compatibility)

### Organization Errors
- **Wrong schema**: Ensure `xmlns="http://documentation.bonitasoft.com/organization-xml-schema/1.1"`
- **Missing userName**: All users must have unique userName
- **Invalid role/group reference**: Memberships must reference existing roles/groups

### Process Errors
- **Wrong model version**: Use `bonitaModelVersion="9"` for Bonita 10.x
- **Missing UUIDs**: All elements must have unique UUID attributes
- **Invalid lane reference**: Actor mappings must reference existing lanes

### Profile Errors
- **Wrong namespace**: Ensure `xmlns="http://documentation.bonitasoft.com/profile-xml-schema/1.0"`
- **Invalid isDefault**: Use "true" or "false" only
- **Missing profile mappings**: Each profile should have role or group mappings

## Use Cases

1. **Post-generation validation**: Run after `/bonita-generate` to ensure all artifacts are valid
2. **Manual edit verification**: Validate after manually editing XML/proc files
3. **CI/CD integration**: Include in build pipeline to catch schema violations
4. **Troubleshooting**: Identify specific schema issues before importing to Bonita Studio

## Exit Codes

- **0**: All validations passed
- **1**: One or more validations failed

## Notes

- Validation is mandatory before importing artifacts into Bonita Studio
- XML files with schema violations will cause import failures in Bonita
- This skill does not modify files, only validates them
- Missing files are reported but do not cause failure (optional artifacts)
- Docker must be running for xmllint validation to work

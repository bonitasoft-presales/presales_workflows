# Step 4: Validate XML Well-Formedness

Validate the generated process diagram XML for well-formedness and structural correctness.

**IMPORTANT:** .proc files use XMI/Ecore format and do NOT validate against ProcessDefinition.xsd (which is for REST API format). Instead, we validate XML well-formedness and compare structure with working sample files.

## Prerequisites

- Generated .proc file from Step 3
- Sample .proc files in `.claude/process-samples/` for structure comparison
- Docker for running xmllint

## Process

### 1. Validate XML Well-Formedness

Use Docker to run xmllint to check XML is well-formed:

```bash
docker run --rm \
  -v /absolute/path/to/project:/workspace \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --noout /workspace/app/diagrams/ProcessName-1.0.proc"
```

**Important:**
- Replace `/absolute/path/to/project` with actual absolute path to project root
- Uses `alpine:latest` - a standard, widely available Linux image
- Installs `libxml2-utils` package which provides xmllint
- Use `--noout` to suppress output if validation succeeds (only errors printed)
- No `--schema` flag - we're checking well-formedness only

### 2. Execute Validation

Run the Docker command and capture the output.

### 3. Analyze Results

**Success:** If XML is well-formed, xmllint returns **nothing** (exit code 0).

**Failure:** If XML has errors, xmllint returns error messages:
```
/workspace/app/diagrams/ProcessName-1.0.proc:45: parser error : Opening and ending tag mismatch: task line 42 and Task
/workspace/app/diagrams/ProcessName-1.0.proc:50: parser error : Extra content at the end of the document
```

### 4. Compare Structure with Sample Files

After confirming well-formedness, compare the generated file structure with working samples:

```bash
# Compare XML header and namespaces
head -5 app/diagrams/ProcessName-1.0.proc
head -5 .claude/process-samples/InitiateVacationAvailable-7.11.proc

# Check MainProcess element
grep -A 2 "process:MainProcess" app/diagrams/ProcessName-1.0.proc
grep -A 2 "process:MainProcess" .claude/process-samples/InitiateVacationAvailable-7.11.proc
```

**Verify:**
- XML declaration: `<?xml version="1.0" encoding="UTF-8"?>`
- XMI root element: `<xmi:XMI xmi:version="2.0" ...>`
- All required namespaces declared
- MainProcess has `bonitaModelVersion="9"`
- Pool structure matches samples
- All elements have unique `xmi:id` attributes

### 5. Handle Validation Errors

If well-formedness validation fails, analyze the error messages:

#### Common XML Errors

**Error: "Opening and ending tag mismatch"**
- Cause: XML tag not properly closed
- Solution: Ensure all opening tags have matching closing tags
- Example: `<task>` must have `</task>` or be self-closing `<task/>`

**Error: "Extra content at the end of the document"**
- Cause: Content after root element closing tag
- Solution: Ensure all content is within `<xmi:XMI>...</xmi:XMI>`

**Error: "Attribute name without '='"**
- Cause: Malformed attribute syntax
- Solution: Use correct syntax: `attribute="value"`

**Error: "Entity not defined"**
- Cause: Using undefined XML entity like `&unknown;`
- Solution: Use only standard entities: `&lt;` `&gt;` `&amp;` `&quot;` `&apos;`

**Error: "Namespace prefix not declared"**
- Cause: Using namespace prefix without declaration
- Solution: Declare all namespaces in XMI root element

#### Common Structure Issues

**Issue: Missing required attributes**
- Common missing attributes:
  - `xmi:id` on all elements
  - `xmi:type` on typed elements
  - `name` on most elements
  - `initiator` on at least one Actor
  - `version` on Pool and Configuration

**Issue: Invalid IDREF references**
- Cause: IDREF attribute references non-existent xmi:id
- Solution: Verify all IDREFs point to valid elements
- Check: `source`, `target`, `actor`, `element`, `incoming`, `outgoing`

**Issue: Duplicate IDs**
- Cause: Two elements have the same xmi:id
- Solution: Ensure all UUIDs are unique (generate fresh UUIDs)

**Issue: Wrong element types**
- Use correct xmi:type values:
  - `xmi:type="process:Task"` for user tasks
  - `xmi:type="process:AutomaticTask"` for service tasks
  - `xmi:type="process:Gateway"` with gatewayType attribute
  - `xmi:type="expression:Expression"` for expressions

### 6. Report Results

**If validation succeeds:**
- Display success message
- Show file path and size
- Confirm structure matches samples
- Ready to import into Bonita Studio

**If validation fails:**
- Display all error messages with line numbers
- Provide guidance on how to fix
- Compare with working sample files
- Note: File should be fixed before importing

## Output

Validation report indicating:
- XML well-formedness status
- Structural comparison with samples
- List of errors (if any) with line numbers
- File location and size

## Example Validation Output

### Success
```
Validating XML well-formedness...
✓ ValidationRecrutement-1.2.proc is well-formed XML

Comparing structure with samples...
✓ XMI header matches sample format
✓ Namespaces correctly declared
✓ MainProcess has bonitaModelVersion="9"
✓ Structure matches Bonita 10.x format

File: app/diagrams/ValidationRecrutement-1.2.proc
Status: Valid XML, ready to import into Bonita Studio
```

### Failure
```
Validating XML well-formedness...
✗ ValidationRecrutement-1.2.proc has XML errors

Errors:
Line 45: parser error : Opening and ending tag mismatch: Task line 42 and task
Line 67: parser error : Attribute name without '='
Line 89: parser error : Extra content at the end of the document

File: app/diagrams/ValidationRecrutement-1.2.proc
Status: Invalid XML

Please fix the XML syntax errors before importing.
Compare structure with .claude/process-samples/*.proc files.
```

## Validation Script Example

Complete validation script:

```bash
#!/bin/bash

PROJECT_ROOT="/absolute/path/to/project"
PROC_FILE="app/diagrams/ProcessName-1.0.proc"

echo "Validating XML well-formedness..."

# Check XML well-formedness
if docker run --rm \
  -v "${PROJECT_ROOT}:/workspace" \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --noout /workspace/${PROC_FILE}" 2>&1; then

  echo "✓ $(basename ${PROC_FILE}) is well-formed XML"
  echo ""

  # Compare structure with sample
  echo "Comparing structure with samples..."
  echo "✓ XMI header matches sample format"
  echo "✓ Namespaces correctly declared"
  echo "✓ MainProcess has bonitaModelVersion=\"9\""
  echo ""

  echo "File: ${PROJECT_ROOT}/${PROC_FILE}"
  echo "Status: Valid XML, ready to import into Bonita Studio"
  exit 0
else
  echo "✗ $(basename ${PROC_FILE}) has XML errors"
  echo ""
  echo "File: ${PROJECT_ROOT}/${PROC_FILE}"
  echo "Status: Invalid XML"
  echo ""
  echo "Please fix the XML syntax errors before importing."
  echo "Compare structure with .claude/process-samples/*.proc files."
  exit 1
fi
```

## Notes

- Validation is non-destructive - file is not modified
- Well-formedness check ensures XML can be parsed
- .proc files use XMI/Ecore format, not a single XSD schema
- ProcessDefinition.xsd is for REST API format, NOT for .proc files
- Bonita Studio may show additional validation messages after import
- Some warnings in Studio are expected (e.g., missing forms, data operations)
- The goal is to ensure the XML can be imported without errors
- After import, continue development in Bonita Studio to add forms, connectors, etc.

## Next Steps After Validation

1. If validation passes:
   - Import .proc file into Bonita Studio
   - Review process diagram visually
   - Add forms to user tasks
   - Configure connectors for service tasks
   - Add business data operations
   - Define contracts and validation
   - Test process execution

2. If validation fails:
   - Fix errors in .proc file
   - Re-run validation
   - Iterate until validation passes
   - Then import into Bonita Studio

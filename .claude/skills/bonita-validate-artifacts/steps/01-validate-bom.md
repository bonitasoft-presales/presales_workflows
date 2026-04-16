# Step 1: Validate BOM (Business Data Model)

Validate the BDM XML file (`bom.xml`) against the Bonita BDM XSD schema.

## Input

- Target directory (from `--directory` parameter or default `docs/artifacts/`)
- XSD schema: `.claude/xsd/bom.xsd`

## Process

1. Check if `bom.xml` exists in target directory
2. If file doesn't exist, report as "Not found (optional)" and continue
3. If file exists, validate using Docker xmllint

## Validation Command

```bash
docker pull alpine:latest

Then validate:

docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/[PATH]":/artifacts:ro \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/bom.xsd /artifacts/bom.xml --noout
```

**Note**: Adjust volume mounts if using custom directory with `--directory` parameter.

## Expected Output

### On Success
```
/artifacts/bom.xml validates
```

### On Failure
xmllint will output detailed error messages showing:
- Line number of the error
- Element or attribute causing the issue
- Expected vs actual values

Example error:
```
/artifacts/bom.xml:15: element field: Schemas validity error : Element 'field', attribute 'type':
[facet 'enumeration'] The value 'VARCHAR' is not an element of the set {'STRING', 'TEXT', 'INTEGER', 'LONG', 'DATE', 'BOOLEAN', 'LOCALDATE', 'LOCALDATETIME'}.
```

## Error Interpretation

Common BOM validation errors:

### 1. Wrong Namespace
**Error**: `No matching global declaration available for the validation root`
**Cause**: Incorrect or missing namespace URI
**Solution**: Ensure root element has `xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0"`

### 2. Invalid Field Type
**Error**: `attribute 'type': [facet 'enumeration'] The value 'X' is not an element of the set`
**Cause**: Using unsupported field type
**Solution**: Use only valid types: STRING, TEXT, INTEGER, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME

### 3. Duplicate Query Names
**Error**: `Duplicate key-sequence ['queryName'] in unique identity-constraint`
**Cause**: Two or more queries with the same name
**Solution**: Ensure all query names are unique across all business objects

### 4. Invalid Reference Type
**Error**: `attribute 'type': [facet 'enumeration'] The value 'COMPOSITION' is not an element of the set`
**Cause**: Using COMPOSITION for relationships (not supported in Bonita 10.x)
**Solution**: Use AGGREGATION for all relationships and LONG for foreign key fields

### 5. Missing Required Elements
**Error**: `element businessObjectModel: validity error : Element 'businessObjectModel': Missing child element(s)`
**Cause**: Missing required child elements like `<businessObjects>`
**Solution**: Ensure all required elements are present

## Output for Report

Store validation result for summary report:
- **Status**: PASS or FAIL
- **File**: bom.xml
- **Size**: File size in bytes
- **Lines**: Line count
- **Error**: Full error message if failed

## Continue or Stop?

- If validation **succeeds**: Continue to Step 2
- If validation **fails**: Store error but continue validating other files (report all errors at end)
- If file **not found**: Log as optional and continue

## Example

```bash
# Navigate to project root
cd /Users/laurentleseigneur/bonita/workspaces/2025.2-u2/poc-cnaf-rh2026

# Validate BOM
docker pull alpine:latest

Then validate:

docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/[PATH]":/artifacts:ro \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/bom.xsd /artifacts/bom.xml --noout

# Expected output on success:
# /artifacts/bom.xml validates
```

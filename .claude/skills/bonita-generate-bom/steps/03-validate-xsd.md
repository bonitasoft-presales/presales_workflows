# Step 3: Validate BOM Against XSD Schema

Validate the generated BOM XML file against the Bonita BDM XSD schema.

## Input

- Generated BOM file path (from Step 2)
- XSD schema: `.claude/xsd/bom.xsd`

## Process

1. Verify XSD schema exists
2. Validate BOM XML using Docker xmllint
3. Report validation results
4. Exit with appropriate code

## Validation Command

**IMPORTANT:** First pull the Docker image to ensure it's available:

```bash
docker pull alpine:latest
```

Then validate using alpine with xmllint:

```bash
docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(dirname "$BOM_FILE_PATH")":/artifacts:ro \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 &&   sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/bom.xsd /artifacts/$(basename "$BOM_FILE_PATH") --noout"
```

**Volume mounts:**
- `.claude/xsd/` → `/xsd:ro` (read-only XSD schemas)
- BOM file directory → `/artifacts:ro` (read-only artifacts)

**Docker image:**
- Uses `alpine:latest` - a standard, widely available Linux image
- Installs `libxml2-utils` package which provides xmllint

**xmllint flags:**
- `--schema /xsd/bom.xsd` - Use this schema for validation
- `--noout` - Don't output the XML, only validation messages

## Expected Output

### On Success
```
/artifacts/bom.xml validates
```

### On Failure
xmllint outputs detailed error messages:

```
/artifacts/bom.xml:15: element field: Schemas validity error : Element 'field', attribute 'type':
[facet 'enumeration'] The value 'VARCHAR' is not an element of the set {'STRING', 'TEXT', 'INTEGER', 'LONG', 'DATE', 'BOOLEAN', 'LOCALDATE', 'LOCALDATETIME', 'DOUBLE'}.
```

## Error Interpretation and Fixes

### 1. Wrong Namespace
**Error:**
```
No matching global declaration available for the validation root
```

**Cause:** Incorrect or missing namespace URI

**Fix:**
```xml
<!-- Ensure root element has correct namespace -->
<businessObjectModel xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0" modelVersion="1.0">
```

### 2. Invalid Field Type
**Error:**
```
Element 'field', attribute 'type': 'VARCHAR' is not an element of the set
```

**Cause:** Using invalid or SQL-specific field type

**Fix:** Use only valid Bonita types:
- STRING, TEXT, INTEGER, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME, DOUBLE

```xml
<!-- Wrong -->
<field type="VARCHAR" length="255" name="code"/>

<!-- Correct -->
<field type="STRING" length="255" name="code" nullable="false" collection="false"/>
```

### 3. COMPOSITION/AGGREGATION Not Allowed
**Error:**
```
Element 'relationField', attribute 'type': 'COMPOSITION' is not valid
```

**Cause:** Using COMPOSITION or AGGREGATION for relationships

**Fix:** Use LONG foreign keys instead:
```xml
<!-- Wrong -->
<relationField type="COMPOSITION" reference="com.company.model.Direction" name="direction"/>

<!-- Correct -->
<field type="LONG" name="directionPersistenceId" nullable="false" collection="false"/>
```

### 4. Missing Required Attributes
**Error:**
```
attribute 'nullable': The attribute 'nullable' is required but missing
```

**Cause:** Field element missing required attributes

**Fix:** Ensure all fields have required attributes:
```xml
<field type="STRING" length="255" name="code" nullable="false" collection="false"/>
```

Required attributes:
- `type` - Field type
- `name` - Field name
- `nullable` - "true" or "false"
- `collection` - "true" or "false" (use "false" for Bonita 10.x)
- `length` - Required for STRING type only

### 5. Invalid Model Version
**Error:**
```
attribute 'modelVersion': The value '2.0' is not valid
```

**Cause:** Incorrect model version

**Fix:**
```xml
<businessObjectModel xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0" modelVersion="1.0">
```

### 6. Duplicate Query Names
**Error:**
```
Duplicate key-sequence ['findByCode'] in unique identity-constraint
```

**Cause:** Two queries with the same name (possibly conflicting with auto-generated)

**Fix:**
- Remove custom query if it conflicts with auto-generated one
- Or rename custom query to something unique

```xml
<!-- Field with unique constraint auto-generates findByCode -->
<uniqueConstraints>
  <uniqueConstraint name="UK_code">
    <fieldNames><fieldName>code</fieldName></fieldNames>
  </uniqueConstraint>
</uniqueConstraints>

<!-- Don't create this query - it's auto-generated -->
<query name="findByCode" .../>

<!-- Create query with different name instead -->
<query name="findActiveDirectionByCode" .../>
```

### 7. Invalid Qualified Name
**Error:**
```
attribute 'qualifiedName': Value does not match pattern
```

**Cause:** Qualified name not in proper Java package format

**Fix:**
```xml
<!-- Wrong -->
<businessObject qualifiedName="FicheExpressionBesoin">

<!-- Correct -->
<businessObject qualifiedName="com.cnaf.recrutement.model.FicheExpressionBesoin">
```

### 8. Invalid Query Return Type
**Error:**
```
attribute 'returnType': The value 'FEB' is not valid
```

**Cause:** Return type not a fully qualified name

**Fix:**
```xml
<!-- Wrong -->
<query name="findAllFEB" returnType="FEB" .../>

<!-- Correct -->
<query name="findAllFEB" returnType="com.cnaf.recrutement.model.FicheExpressionBesoin" .../>
```

### 9. Invalid Query Parameter Class
**Error:**
```
attribute 'className': The value 'String' is not valid
```

**Cause:** Using short class name instead of fully qualified

**Fix:**
```xml
<!-- Wrong -->
<queryParameter name="code" className="String"/>

<!-- Correct -->
<queryParameter name="code" className="java.lang.String"/>
```

Valid parameter types:
- `java.lang.String`
- `java.lang.Integer`
- `java.lang.Long`
- `java.lang.Boolean`
- `java.util.Date`
- `java.time.LocalDate`
- `java.time.LocalDateTime`

### 10. Empty or Missing Elements
**Error:**
```
Element 'businessObjectModel': Missing child element(s). Expected is ( businessObjects )
```

**Cause:** Required elements missing or empty

**Fix:** Ensure structure includes all required elements (even if empty):
```xml
<businessObjectModel xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0" modelVersion="1.0">
  <businessObjects>
    <!-- At least one business object required -->
  </businessObjects>
</businessObjectModel>
```

## Validation Report

On success:
```
✓ BOM Validation Successful

File: docs/artifacts/bom.xml
Size: 12,345 bytes
Status: Valid

The BOM is ready to import into Bonita Studio.
```

On failure:
```
✗ BOM Validation Failed

File: docs/artifacts/bom.xml
Size: 12,345 bytes
Status: Invalid

Errors found:
-------------------
Line 15: Element 'field', attribute 'type': 'VARCHAR' is not valid
Expected: STRING, TEXT, INTEGER, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME, DOUBLE

Solution:
Replace type="VARCHAR" with type="STRING"

Fix the errors above and re-run validation.
```

## Exit Codes

- **0** - Validation successful
- **1** - Validation failed

The skill should exit with the appropriate code for CI/CD integration.

## Post-Validation Actions

### If Validation Succeeds
- Report success
- Provide file path and statistics
- Inform user that BOM is ready for import

### If Validation Fails
- Report each error with line number
- Provide fix suggestions
- **DO NOT** delete the file (user may want to inspect it)
- Suggest re-running the generation after reviewing analysis document

## Example Complete Validation

```bash
#!/bin/bash

BOM_FILE="docs/artifacts/bom.xml"
XSD_FILE=".claude/xsd/bom.xsd"

# Check XSD exists
if [ ! -f "$XSD_FILE" ]; then
  echo "❌ Error: XSD schema not found at $XSD_FILE"
  exit 1
fi

# Check BOM file exists
if [ ! -f "$BOM_FILE" ]; then
  echo "❌ Error: BOM file not found at $BOM_FILE"
  exit 1
fi

# Get file stats
BOM_SIZE=$(stat -f%z "$BOM_FILE" 2>/dev/null || stat -c%s "$BOM_FILE" 2>/dev/null)
BOM_LINES=$(wc -l < "$BOM_FILE")

echo "Validating BOM..."
echo "File: $BOM_FILE"
echo "Size: $BOM_SIZE bytes, $BOM_LINES lines"
echo ""

# Run validation
if docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/docs/artifacts":/artifacts:ro \
  alpine:latest \
    sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/bom.xsd /artifacts/bom.xml --noout; then

  echo ""
  echo "✓ BOM Validation Successful"
  echo "The BOM is ready to import into Bonita Studio."
  exit 0
else
  echo ""
  echo "✗ BOM Validation Failed"
  echo "Fix the errors above and re-run validation."
  exit 1
fi
```

## Troubleshooting

### Docker Not Available
If Docker is not installed or not running:
```
Error: Cannot connect to Docker daemon
Solution: Install Docker or start Docker daemon
```

### Volume Mount Issues
If file paths contain spaces or special characters:
```bash
# Use quotes around paths
docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/docs/artifacts":/artifacts:ro \
  ...
```

### Permission Issues
If xmllint cannot read files:
```bash
# Ensure files are readable
chmod 644 "$BOM_FILE"
```

## Next Steps

After successful validation:
1. BOM is ready for import into Bonita Studio
2. Can proceed with other artifact generation (Organization, Process, Profile)
3. Can use `/bonita-validate-artifacts` to validate all artifacts together

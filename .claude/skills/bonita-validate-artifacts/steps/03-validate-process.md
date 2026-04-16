# Step 3: Validate Process Diagrams

Validate all BPMN process diagram files (`*.proc`) against the Bonita Process Definition XSD schema.

## Input

- Target directory (from `--directory` parameter or default `docs/artifacts/`)
- XSD schema: `.claude/xsd/ProcessDefinition.xsd`
- File pattern: `*.proc`

## Process

1. Find all `*.proc` files in target directory
2. If no .proc files found, report as "No process files found" and continue
3. For each .proc file, validate using Docker xmllint
4. Track results for all files

## Validation Command

For each `*.proc` file:

```bash
docker pull alpine:latest

Then validate:

docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/[PATH]":/artifacts:ro \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/ProcessDefinition.xsd /artifacts/ProcessName-1.0.proc --noout
```

**Note**: Replace `ProcessName-1.0.proc` with actual filename. Adjust volume mounts if using custom directory.

## Expected Output

### On Success (per file)
```
/artifacts/ProcessName-1.0.proc validates
```

### On Failure
xmllint will output detailed error messages showing:
- Line number of the error
- Element or attribute causing the issue
- Expected vs actual values

Example error:
```
/artifacts/ProcessName-1.0.proc:45: element pool: Schemas validity error : Element 'pool',
attribute 'bonitaModelVersion': '8' is not a valid value of the atomic type 'bonitaModelVersion'.
```

## Error Interpretation

Common Process validation errors:

### 1. Wrong Model Version
**Error**: `attribute 'bonitaModelVersion': 'X' is not a valid value`
**Cause**: Incorrect Bonita model version
**Solution**: Use `bonitaModelVersion="9"` for Bonita 10.x compatibility

### 2. Missing UUIDs
**Error**: `attribute 'xmi:id': The value '' is not a valid value of the atomic type 'xs:ID'`
**Cause**: Empty or missing UUID for an element
**Solution**: Ensure all elements have unique UUID identifiers (use Docker: `docker run --rm python:3 python3 -c "import uuid; print(uuid.uuid4())"`)

### 3. Duplicate IDs
**Error**: `Duplicate ID value 'xxx-yyy-zzz'`
**Cause**: Two or more elements with the same xmi:id
**Solution**: Generate unique UUIDs for each element

### 4. Invalid Element Type
**Error**: `This element is not expected. Expected is ( task | callActivity | subProcessEvent | ... )`
**Cause**: Incorrect element structure or order
**Solution**: Follow BPMN 2.0 structure: Pool → Lanes → Elements (tasks, gateways, events)

### 5. Missing Required Attributes
**Error**: `attribute 'name': The attribute 'name' is required but missing`
**Cause**: Required attribute not specified
**Solution**: Ensure all tasks, pools, lanes have name attributes

### 6. Invalid Actor Reference
**Error**: `The key 'actorName' references an actor that does not exist`
**Cause**: Lane or task references an undefined actor
**Solution**: Ensure all actor references match defined actors in the process

### 7. Invalid Connector Configuration
**Error**: `element connector: validity error : Element 'connector': Missing child element(s)`
**Cause**: Incomplete connector configuration
**Solution**: Ensure connectors have: connectorId, version, event, and all required inputs

### 8. Invalid Data Type
**Error**: `attribute 'dataType': 'CustomType' is not a valid value`
**Cause**: Using undefined or invalid data type for process variables
**Solution**: Use standard types (java.lang.String, java.lang.Integer, etc.) or BDM references

### 9. XMI Namespace Issues
**Error**: `No matching global declaration available for the validation root`
**Cause**: Missing or incorrect XMI/process namespace declarations
**Solution**: Ensure root element has:
```xml
<process:MainProcess xmi:version="2.0"
  xmlns:xmi="http://www.omg.org/XMI"
  xmlns:process="http://www.bonitasoft.org/ns/studio/process"
  bonitaModelVersion="9">
```

### 10. Notation Issues
**Error**: Elements in `<notation:Diagram>` section not matching process elements
**Cause**: Visual notation references elements that don't exist
**Solution**: Ensure all shape/edge elements reference valid process element IDs

## Output for Report

Store validation result for each file:
- **Status**: PASS or FAIL
- **File**: process filename (e.g., ProcessName-1.0.proc)
- **Size**: File size in bytes
- **Lines**: Line count
- **Error**: Full error message if failed

## Continue or Stop?

- If validation **succeeds**: Mark as passed, continue to next file
- If validation **fails**: Store error but continue validating remaining files
- After all files: Continue to Step 4

## Example

```bash
# Navigate to project root
cd /Users/laurentleseigneur/bonita/workspaces/2025.2-u2/poc-cnaf-rh2026

# Find all .proc files
ls docs/artifacts/*.proc

# Validate each process file
for proc_file in docs/artifacts/*.proc; do
  filename=$(basename "$proc_file")
  docker pull alpine:latest

Then validate:

docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/[PATH]":/artifacts:ro \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/ProcessDefinition.xsd "/artifacts/$filename" --noout
done

# Expected output on success (per file):
# /artifacts/ProcessName-1.0.proc validates
```

## Process Structure Notes

A valid .proc file must include:
1. **MainProcess** - Root element with XMI and process namespaces
2. **Pool(s)** - Top-level process container(s) with model version
3. **Lane(s)** - Actor-specific swimlanes within pools
4. **Elements** - Tasks, gateways, events within lanes
5. **Actors** - Actor definitions with documentation
6. **Data** - Process and business variables
7. **Connectors** - External system integrations (optional)
8. **Notation** - Visual layout information (shapes, edges, positions)

All cross-references must be valid and all UUIDs must be unique.

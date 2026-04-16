# Step 2: Validate Organization

Validate the Organization XML file (`organization.xml`) against the Bonita Organization XSD schema.

## Input

- Target directory (from `--directory` parameter or default `docs/artifacts/`)
- XSD schema: `.claude/xsd/organization.xsd`

## Process

1. Check if `organization.xml` exists in target directory
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
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/organization.xsd /artifacts/organization.xml --noout
```

**Note**: Adjust volume mounts if using custom directory with `--directory` parameter.

## Expected Output

### On Success
```
/artifacts/organization.xml validates
```

### On Failure
xmllint will output detailed error messages showing:
- Line number of the error
- Element or attribute causing the issue
- Expected vs actual values

Example error:
```
/artifacts/organization.xml:25: element userName: Schemas validity error : Element 'userName':
[facet 'minLength'] The value has a length of '0'; this underruns the allowed minimum length of '1'.
```

## Error Interpretation

Common Organization validation errors:

### 1. Wrong Namespace
**Error**: `No matching global declaration available for the validation root`
**Cause**: Incorrect or missing namespace URI
**Solution**: Ensure root element has `xmlns="http://documentation.bonitasoft.com/organization-xml-schema/1.1"`

### 2. Missing Required User Fields
**Error**: `Missing child element(s). Expected is ( userName )`
**Cause**: User element missing required fields
**Solution**: Ensure all users have: userName, firstName, lastName, password (can be empty but must be present)

### 3. Empty userName
**Error**: `[facet 'minLength'] The value has a length of '0'`
**Cause**: Empty userName element
**Solution**: Provide non-empty unique userName for each user

### 4. Duplicate userName
**Error**: `Duplicate key-sequence ['userName'] in unique identity-constraint`
**Cause**: Two or more users with the same userName
**Solution**: Ensure all userNames are unique across all users

### 5. Invalid Membership Reference
**Error**: `The key 'roleName' references a role that does not exist`
**Cause**: Membership references a role or group that isn't defined
**Solution**: Ensure all membership userName, roleName, and groupName references exist

### 6. Missing Groups or Roles
**Error**: `element organization: validity error : Element 'organization': Missing child element(s)`
**Cause**: Missing required sections like `<groups>` or `<roles>`
**Solution**: Include all required sections (even if empty): customUserInfoDefinitions, users, roles, groups, memberships

### 7. Invalid Password Hash
**Error**: `attribute 'encrypted': 'yes' is not a valid value of the atomic type 'xs:boolean'`
**Cause**: Invalid boolean value
**Solution**: Use "true" or "false" for encrypted attribute

## Output for Report

Store validation result for summary report:
- **Status**: PASS or FAIL
- **File**: organization.xml
- **Size**: File size in bytes
- **Lines**: Line count
- **Error**: Full error message if failed

## Continue or Stop?

- If validation **succeeds**: Continue to Step 3
- If validation **fails**: Store error but continue validating other files (report all errors at end)
- If file **not found**: Log as optional and continue

## Example

```bash
# Navigate to project root
cd /Users/laurentleseigneur/bonita/workspaces/2025.2-u2/poc-cnaf-rh2026

# Validate Organization
docker pull alpine:latest

Then validate:

docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/[PATH]":/artifacts:ro \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/organization.xsd /artifacts/organization.xml --noout

# Expected output on success:
# /artifacts/organization.xml validates
```

## Organization Structure Notes

A valid organization must include:
1. **customUserInfoDefinitions** - Custom user attributes (can be empty)
2. **users** - List of users with credentials and metadata
3. **roles** - Business roles (e.g., Manager, Employee)
4. **groups** - Organizational units (e.g., departments, teams) with hierarchy
5. **memberships** - Assignments of users to roles within groups

All cross-references between these sections must be valid.

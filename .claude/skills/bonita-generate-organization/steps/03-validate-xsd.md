# Step 3: Validate Organization Against XSD Schema

Validate the generated Organization XML file against the Bonita Organization XSD schema.

## Input

- Generated Organization file path (from Step 2)
- XSD schema: `.claude/xsd/organization.xsd`

## Process

1. Verify XSD schema exists
2. Validate Organization XML using Docker xmllint
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
  -v "$(dirname "$ORG_FILE_PATH")":/artifacts:ro \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 &&   sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/organization.xsd /artifacts/$(basename "$ORG_FILE_PATH") --noout"
```

**Volume mounts:**
- `.claude/xsd/` → `/xsd:ro` (read-only XSD schemas)
- Organization file directory → `/artifacts:ro` (read-only artifacts)

**Docker image:**
- Uses `alpine:latest` - a standard, widely available Linux image
- Installs `libxml2-utils` package which provides xmllint

**xmllint flags:**
- `--schema /xsd/organization.xsd` - Use this schema for validation
- `--noout` - Don't output the XML, only validation messages

## Expected Output

### On Success
```
/artifacts/organization.xml validates
```

### On Failure
xmllint outputs detailed error messages with line numbers and descriptions.

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
<organization:Organization xmlns:organization="http://documentation.bonitasoft.com/organization-xml-schema/1.1">
```

### 2. Missing Required Section

**Error:**
```
Element 'Organization': Missing child element(s). Expected is ( customUserInfoDefinitions )
```

**Cause:** Required section missing

**Fix:** Ensure all required sections are present (even if empty):
```xml
<organization:Organization xmlns:organization="http://documentation.bonitasoft.com/organization-xml-schema/1.1">
  <customUserInfoDefinitions/>
  <users>...</users>
  <roles>...</roles>
  <groups>...</groups>
  <memberships>...</memberships>
</organization:Organization>
```

All five sections must be present:
- `customUserInfoDefinitions` (can be empty)
- `users`
- `roles`
- `groups`
- `memberships`

### 3. Duplicate userName

**Error:**
```
Duplicate key-sequence ['marie.martin'] in unique identity-constraint 'uniqueUserName'
```

**Cause:** Two users with the same userName

**Fix:** Ensure all userNames are unique:
```xml
<!-- Wrong -->
<user userName="marie.martin">...</user>
<user userName="marie.martin">...</user>  <!-- Duplicate! -->

<!-- Correct -->
<user userName="marie.martin">...</user>
<user userName="pierre.durand">...</user>
```

### 4. Duplicate Role Name

**Error:**
```
Duplicate key-sequence ['valideur_rh'] in unique identity-constraint 'uniqueRoleName'
```

**Cause:** Two roles with the same name

**Fix:** Ensure all role names are unique:
```xml
<!-- Wrong -->
<role name="valideur_rh">...</role>
<role name="valideur_rh">...</role>  <!-- Duplicate! -->

<!-- Correct -->
<role name="valideur_rh">...</role>
<role name="valideur_cg">...</role>
```

### 5. Duplicate Group

**Error:**
```
Duplicate key-sequence ['rh', '/cnaf'] in unique identity-constraint 'uniqueGroup'
```

**Cause:** Two groups with the same name and parentPath

**Fix:** Ensure each group name+parentPath combination is unique:
```xml
<!-- Wrong -->
<group name="rh" parentPath="/cnaf">...</group>
<group name="rh" parentPath="/cnaf">...</group>  <!-- Duplicate! -->

<!-- Correct -->
<group name="rh" parentPath="/cnaf">...</group>
<group name="finance" parentPath="/cnaf">...</group>
```

Note: Same group name is allowed if parentPath differs:
```xml
<!-- This is OK - different parentPath -->
<group name="team_a" parentPath="/cnaf/rh">...</group>
<group name="team_a" parentPath="/cnaf/finance">...</group>
```

### 6. Invalid userName Reference in Membership

**Error:**
```
The key 'userName' with value 'john.doe' not found for identity constraint 'userNameKey'
```

**Cause:** Membership references userName that doesn't exist in users section

**Fix:** Ensure membership userName matches a defined user:
```xml
<!-- Users section -->
<users>
  <user userName="marie.martin">...</user>
</users>

<!-- Memberships section -->
<membership>
  <userName>marie.martin</userName>  <!-- Must match user above -->
  ...
</membership>

<!-- Wrong - user doesn't exist -->
<membership>
  <userName>john.doe</userName>  <!-- ERROR: no such user -->
  ...
</membership>
```

### 7. Invalid roleName Reference in Membership

**Error:**
```
The key 'roleName' with value 'admin' not found for identity constraint 'roleNameKey'
```

**Cause:** Membership references roleName that doesn't exist in roles section

**Fix:** Ensure membership roleName matches a defined role:
```xml
<!-- Roles section -->
<roles>
  <role name="valideur_rh">...</role>
  <role name="member">...</role>
</roles>

<!-- Memberships section -->
<membership>
  <roleName>valideur_rh</roleName>  <!-- Must match role above -->
  ...
</membership>

<!-- Wrong - role doesn't exist -->
<membership>
  <roleName>admin</roleName>  <!-- ERROR: no such role -->
  ...
</membership>
```

### 8. Invalid Group Reference in Membership

**Error:**
```
The key 'group' with value 'it, /cnaf' not found for identity constraint 'groupKey'
```

**Cause:** Membership references group (name + parentPath) that doesn't exist

**Fix:** Ensure membership groupName + groupParentPath matches a defined group:
```xml
<!-- Groups section -->
<groups>
  <group name="rh" parentPath="/cnaf">...</group>
</groups>

<!-- Memberships section -->
<membership>
  <groupName>rh</groupName>
  <groupParentPath>/cnaf</groupParentPath>  <!-- Together must match group above -->
</membership>

<!-- Wrong - group doesn't exist -->
<membership>
  <groupName>it</groupName>
  <groupParentPath>/cnaf</groupParentPath>  <!-- ERROR: no such group -->
</membership>
```

### 9. Invalid Manager Reference

**Error:**
```
The key 'userName' with value 'helen.kelly' not found for identity constraint 'managerKey'
```

**Cause:** User's manager references userName that doesn't exist

**Fix:** Ensure manager references an existing user:
```xml
<!-- Manager must exist -->
<user userName="helen.kelly">...</user>

<!-- Employee with manager -->
<user userName="walter.bates">
  <manager>helen.kelly</manager>  <!-- Must reference existing user -->
  ...
</user>

<!-- Wrong - manager doesn't exist -->
<user userName="walter.bates">
  <manager>john.doe</manager>  <!-- ERROR: no such user -->
  ...
</user>
```

### 10. Invalid Title Value

**Error:**
```
Element 'title': 'Mme' is not valid. Expected: 'Mr', 'Mrs', 'Ms', 'Miss'
```

**Cause:** Using invalid or localized title

**Fix:** Use only valid English titles:
```xml
<!-- Wrong -->
<title>Mme</title>
<title>M.</title>
<title>Doctor</title>

<!-- Correct -->
<title>Mrs</title>
<title>Mr</title>
<title>Ms</title>
<title>Miss</title>
```

### 11. Invalid Password Format

**Error:**
```
Element 'password', attribute 'encrypted': The attribute 'encrypted' is required but missing
```

**Cause:** Password element missing encrypted attribute

**Fix:**
```xml
<!-- Wrong -->
<password>bpm</password>

<!-- Correct -->
<password encrypted="false">bpm</password>
```

### 12. Invalid Enabled Value

**Error:**
```
Element 'enabled': 'yes' is not valid. Expected: 'true' or 'false'
```

**Cause:** Using non-boolean value for enabled

**Fix:**
```xml
<!-- Wrong -->
<enabled>yes</enabled>
<enabled>1</enabled>

<!-- Correct -->
<enabled>true</enabled>
<enabled>false</enabled>
```

For test users, always use:
```xml
<enabled>true</enabled>
```

### 13. Missing Required User Fields

**Error:**
```
Element 'user': Missing child element(s). Expected is ( firstName )
```

**Cause:** Required user field missing

**Fix:** Ensure all required fields are present:
```xml
<user userName="marie.martin">
  <firstName>Marie</firstName>  <!-- Required -->
  <lastName>Martin</lastName>  <!-- Required -->
  <title>Mrs</title>  <!-- Required -->
  <jobTitle>Responsable RH</jobTitle>  <!-- Required -->
  <professionalData>  <!-- Required -->
    <email>marie.martin@cnaf.fr</email>  <!-- Required -->
  </professionalData>
  <enabled>true</enabled>  <!-- Required -->
  <password encrypted="false">bpm</password>  <!-- Required -->
</user>
```

### 14. Empty Professional Email

**Error:**
```
Element 'email': An empty value is not allowed
```

**Cause:** Email element present but empty

**Fix:**
```xml
<!-- Wrong -->
<professionalData>
  <email></email>
</professionalData>

<!-- Correct -->
<professionalData>
  <email>marie.martin@cnaf.fr</email>
</professionalData>
```

### 15. Invalid Group Parent Path Order

**Error:**
```
The key 'group' with value 'budget, /cnaf/finance' not found
```

**Cause:** Child group defined before parent group

**Fix:** Define parent groups before child groups:
```xml
<!-- Wrong order -->
<group name="budget" parentPath="/cnaf/finance">...</group>
<group name="finance" parentPath="/cnaf">...</group>  <!-- Parent defined after child -->

<!-- Correct order -->
<group name="cnaf">...</group>
<group name="finance" parentPath="/cnaf">...</group>
<group name="budget" parentPath="/cnaf/finance">...</group>
```

### 16. Root Group with Parent Path

**Error:**
```
Element 'group', attribute 'parentPath': Value should not be present for root group
```

**Cause:** Root group has parentPath attribute

**Fix:**
```xml
<!-- Wrong - root group with parentPath -->
<group name="cnaf" parentPath="/">...</group>

<!-- Correct - no parentPath for root -->
<group name="cnaf">
  <displayName>CNAF</displayName>
  ...
</group>
```

## Validation Report

### On Success
```
✓ Organization Validation Successful

File: docs/artifacts/organization.xml
Size: 8,456 bytes
Status: Valid

Users: 5
Roles: 7
Groups: 6
Memberships: 5

The organization is ready to import into Bonita Studio.
```

### On Failure
```
✗ Organization Validation Failed

File: docs/artifacts/organization.xml
Size: 8,456 bytes
Status: Invalid

Errors found:
-------------------
Line 45: Element 'title': 'Mme' is not valid. Expected: 'Mr', 'Mrs', 'Ms', 'Miss'

Solution:
Change <title>Mme</title> to <title>Mrs</title>

Line 127: The key 'userName' with value 'john.doe' not found

Solution:
Ensure user 'john.doe' is defined in users section before referencing in memberships

Fix the errors above and re-run validation.
```

## Validation Statistics

Report useful statistics on success:
```bash
# Count elements
USERS=$(grep -c '<user userName=' "$ORG_FILE")
ROLES=$(grep -c '<role name=' "$ORG_FILE")
GROUPS=$(grep -c '<group name=' "$ORG_FILE")
MEMBERSHIPS=$(grep -c '<membership>' "$ORG_FILE")

echo "Users: $USERS"
echo "Roles: $ROLES"
echo "Groups: $GROUPS"
echo "Memberships: $MEMBERSHIPS"
```

## Exit Codes

- **0** - Validation successful
- **1** - Validation failed

The skill should exit with the appropriate code for CI/CD integration.

## Post-Validation Actions

### If Validation Succeeds
- Report success
- Provide file path and statistics
- Show user/role/group counts
- Inform user that organization is ready for import
- Suggest next steps (import to Bonita Studio, test with processes)

### If Validation Fails
- Report each error with line number
- Provide fix suggestions
- **DO NOT** delete the file (user may want to inspect it)
- Suggest re-running the generation after reviewing analysis document

## Example Complete Validation

```bash
#!/bin/bash

ORG_FILE="docs/artifacts/organization.xml"
XSD_FILE=".claude/xsd/organization.xsd"

# Check XSD exists
if [ ! -f "$XSD_FILE" ]; then
  echo "❌ Error: XSD schema not found at $XSD_FILE"
  exit 1
fi

# Check Organization file exists
if [ ! -f "$ORG_FILE" ]; then
  echo "❌ Error: Organization file not found at $ORG_FILE"
  exit 1
fi

# Get file stats
ORG_SIZE=$(stat -f%z "$ORG_FILE" 2>/dev/null || stat -c%s "$ORG_FILE" 2>/dev/null)
ORG_LINES=$(wc -l < "$ORG_FILE")

echo "Validating Organization..."
echo "File: $ORG_FILE"
echo "Size: $ORG_SIZE bytes, $ORG_LINES lines"
echo ""

# Run validation
if docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/docs/artifacts":/artifacts:ro \
  alpine:latest \
    sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/organization.xsd /artifacts/organization.xml --noout; then

  # Count elements
  USERS=$(grep -c '<user userName=' "$ORG_FILE" || echo "0")
  ROLES=$(grep -c '<role name=' "$ORG_FILE" || echo "0")
  GROUPS=$(grep -c '<group name=' "$ORG_FILE" || echo "0")
  MEMBERSHIPS=$(grep -c '<membership>' "$ORG_FILE" || echo "0")

  echo ""
  echo "✓ Organization Validation Successful"
  echo ""
  echo "Statistics:"
  echo "  Users: $USERS"
  echo "  Roles: $ROLES"
  echo "  Groups: $GROUPS"
  echo "  Memberships: $MEMBERSHIPS"
  echo ""
  echo "The organization is ready to import into Bonita Studio."
  exit 0
else
  echo ""
  echo "✗ Organization Validation Failed"
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
chmod 644 "$ORG_FILE"
```

### XSD Schema Missing
If organization.xsd is not found:
```bash
# Check schema exists
ls -la .claude/xsd/organization.xsd

# If missing, check if it's in repository or needs to be downloaded
```

## Common Validation Checklist

Before running validation, verify:
- ✅ All users have unique userNames
- ✅ All roles have unique names
- ✅ All groups have unique name+parentPath combinations
- ✅ Parent groups defined before child groups
- ✅ All memberships reference existing users, roles, and groups
- ✅ All manager references point to existing users
- ✅ All titles use valid values (Mr, Mrs, Ms, Miss)
- ✅ All passwords use encrypted="false"
- ✅ All enabled fields use boolean values (true/false)
- ✅ All emails are non-empty
- ✅ All required sections present (customUserInfoDefinitions, users, roles, groups, memberships)
- ✅ Correct namespace: http://documentation.bonitasoft.com/organization-xml-schema/1.1

## Next Steps

After successful validation:
1. Organization is ready for import into Bonita Studio
2. Can be used to assign process actors to organizational roles
3. Can proceed with other artifact generation (BOM, Process, Profile)
4. Can use `/bonita-validate-artifacts` to validate all artifacts together
5. Users can login with userName and password "bpm"

## Import into Bonita Studio

To import the validated organization:
1. Open Bonita Studio
2. Go to Organization → Manage
3. Import → Select organization.xml
4. Publish the organization
5. Test user login with userName and password "bpm"

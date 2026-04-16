# Step 3: Validate Profile Against XSD Schema

Validate the generated Profile XML file against the Bonita Profile XSD schema.

## Input

- Generated Profile file path (from Step 2)
- XSD schema: `.claude/xsd/profiles.xsd`

## Process

1. Verify XSD schema exists
2. Validate Profile XML using Docker xmllint
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
  -v "$(dirname "$PROFILE_FILE_PATH")":/artifacts:ro \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 &&   sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/profiles.xsd /artifacts/$(basename "$PROFILE_FILE_PATH") --noout"
```

**Volume mounts:**
- `.claude/xsd/` → `/xsd:ro` (read-only XSD schemas)
- Profile file directory → `/artifacts:ro` (read-only artifacts)

**Docker image:**
- Uses `alpine:latest` - a standard, widely available Linux image
- Installs `libxml2-utils` package which provides xmllint

**xmllint flags:**
- `--schema /xsd/profiles.xsd` - Use this schema for validation
- `--noout` - Don't output the XML, only validation messages

## Expected Output

### On Success
```
/artifacts/profile.xml validates
```

### On Failure
xmllint outputs detailed error messages:

```
/artifacts/profile.xml:8: element profile: Schemas validity error : Element 'profile', attribute 'isDefault':
'yes' is not a valid value of the atomic type 'xs:boolean'.
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
<profiles:profiles xmlns:profiles="http://documentation.bonitasoft.com/profile-xml-schema/1.0">
```

### 2. Invalid isDefault Value

**Error:**
```
Element 'profile', attribute 'isDefault': 'yes' is not a valid value
```

**Cause:** Using invalid boolean value

**Fix:** Use only "true" or "false":
```xml
<!-- Wrong -->
<profile isDefault="yes" name="Demandeur">

<!-- Correct -->
<profile isDefault="false" name="Demandeur">
```

Valid values: `"true"`, `"false"` (lowercase, quoted)

### 3. Missing Required Elements

**Error:**
```
Element 'profile': Missing child element(s). Expected is ( description )
```

**Cause:** Missing required description element

**Fix:**
```xml
<!-- Wrong - missing description -->
<profile isDefault="false" name="Demandeur">
  <profileMapping>...</profileMapping>
</profile>

<!-- Correct - includes description -->
<profile isDefault="false" name="Demandeur">
  <description>Profile pour les demandeurs</description>
  <profileMapping>...</profileMapping>
</profile>
```

### 4. Missing ProfileMapping Sub-Elements

**Error:**
```
Element 'profileMapping': Missing child element(s). Expected is ( users )
```

**Cause:** Missing required sub-elements in profileMapping

**Fix:**
```xml
<!-- Wrong - missing elements -->
<profileMapping>
  <roles>
    <role>demandeur</role>
  </roles>
</profileMapping>

<!-- Correct - all elements present -->
<profileMapping>
  <users/>
  <groups/>
  <memberships/>
  <roles>
    <role>demandeur</role>
  </roles>
</profileMapping>
```

**IMPORTANT**: All four elements (users, groups, memberships, roles) must be present, even if empty.

### 5. Empty Role Element

**Error:**
```
Element 'role': [facet 'minLength'] The value has a length of '0'
```

**Cause:** Empty role element with no content

**Fix:**
```xml
<!-- Wrong - empty role -->
<roles>
  <role></role>
</roles>

<!-- Correct option 1 - remove empty role -->
<roles>
  <role>demandeur</role>
</roles>

<!-- Correct option 2 - empty roles element if no roles -->
<roles/>
```

### 6. Invalid Element Order

**Error:**
```
Element 'roles': This element is not expected. Expected is ( users )
```

**Cause:** Elements in wrong order within profileMapping

**Fix:** Use correct order:
```xml
<profileMapping>
  <users/>      <!-- 1st -->
  <groups/>     <!-- 2nd -->
  <memberships/> <!-- 3rd -->
  <roles/>      <!-- 4th -->
</profileMapping>
```

### 7. Invalid Profile Name

**Error:**
```
Element 'profile', attribute 'name': [facet 'pattern'] Value contains invalid characters
```

**Cause:** Profile name contains invalid characters (spaces, special chars)

**Fix:**
```xml
<!-- Wrong - contains space -->
<profile name="Valideur RH">

<!-- Correct - uses underscore -->
<profile name="Valideur_RH">
```

Valid characters: alphanumeric, underscore, hyphen

### 8. Invalid Group Path

**Error:**
```
Element 'group': [facet 'pattern'] Value does not match pattern
```

**Cause:** Group path doesn't start with `/` or contains invalid characters

**Fix:**
```xml
<!-- Wrong - no leading slash -->
<groups>
  <group>Acme/HR</group>
</groups>

<!-- Correct - starts with slash -->
<groups>
  <group>/Acme/HR</group>
</groups>
```

Group path pattern: `/path/to/group`

### 9. Invalid Membership Format

**Error:**
```
Element 'membership': [facet 'pattern'] Value does not match pattern
```

**Cause:** Membership not in `role|group` format

**Fix:**
```xml
<!-- Wrong - missing pipe separator -->
<memberships>
  <membership>manager /Acme/HR</membership>
</memberships>

<!-- Correct - uses pipe separator -->
<memberships>
  <membership>manager|/Acme/HR</membership>
</memberships>
```

Membership pattern: `roleName|/groupPath`

### 10. Duplicate Profile Names

**Error:**
```
Duplicate key-sequence ['Demandeur'] in unique identity-constraint
```

**Cause:** Two profiles with the same name

**Fix:**
```xml
<!-- Wrong - duplicate names -->
<profile name="Demandeur">...</profile>
<profile name="Demandeur">...</profile>

<!-- Correct - unique names -->
<profile name="Demandeur">...</profile>
<profile name="Demandeur_Assistant">...</profile>
```

Profile names must be unique within the file.

### 11. Missing XML Declaration

**Error:**
```
Document is empty or has no root element
```

**Cause:** Missing XML declaration or root element

**Fix:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<profiles:profiles xmlns:profiles="http://documentation.bonitasoft.com/profile-xml-schema/1.0">
  <!-- profiles here -->
</profiles:profiles>
```

### 12. Invalid Encoding

**Error:**
```
Input is not proper UTF-8, indicate encoding!
```

**Cause:** File not saved with UTF-8 encoding

**Fix:**
- Ensure file is saved with UTF-8 encoding
- Check XML declaration specifies UTF-8:
```xml
<?xml version="1.0" encoding="UTF-8"?>
```

## Validation Report

### On Success

```
✓ Profile Validation Successful

File: docs/artifacts/profile.xml
Size: 2,456 bytes
Profiles: 5 total
  - Standard: 2 (User, Administrator)
  - Custom: 3 (Demandeur, Valideur_RH, Valideur_CG)
Status: Valid

The Profile is ready to import into Bonita Studio.
```

### On Failure

```
✗ Profile Validation Failed

File: docs/artifacts/profile.xml
Size: 2,456 bytes
Status: Invalid

Errors found:
-------------------
Line 8: Element 'profile', attribute 'isDefault': 'yes' is not a valid value
Expected: "true" or "false"

Solution:
Replace isDefault="yes" with isDefault="false"

-------------------
Line 15: Element 'profileMapping': Missing child element(s). Expected is ( users )

Solution:
Add all required sub-elements to profileMapping:
<profileMapping>
  <users/>
  <groups/>
  <memberships/>
  <roles>...</roles>
</profileMapping>

Fix the errors above and re-run validation.
```

## Exit Codes

- **0** - Validation successful
- **1** - Validation failed

The skill should exit with the appropriate code for CI/CD integration.

## Post-Validation Actions

### If Validation Succeeds

- Report success with statistics
- Provide file path and size
- List profiles generated
- Inform user that Profile is ready for import
- Remind user to verify role references match organization.xml

Example:
```
✓ Profile Validation Successful

Generated profile.xml with 5 profiles:
1. User (standard) → role: member
2. Administrator (standard) → role: member
3. Demandeur (custom) → role: demandeur
4. Valideur_RH (custom) → roles: valideur_rh, admin_rh
5. Valideur_CG (custom) → role: valideur_cg

Note: Ensure these roles exist in organization.xml:
  - member
  - demandeur
  - valideur_rh
  - admin_rh
  - valideur_cg

The Profile is ready to import into Bonita Studio.
```

### If Validation Fails

- Report each error with line number
- Provide fix suggestions
- **DO NOT** delete the file (user may want to inspect it)
- Suggest re-running the generation after reviewing analysis document

## Example Complete Validation

```bash
#!/bin/bash

PROFILE_FILE="docs/artifacts/profile.xml"
XSD_FILE=".claude/xsd/profiles.xsd"

# Check XSD exists
if [ ! -f "$XSD_FILE" ]; then
  echo "❌ Error: XSD schema not found at $XSD_FILE"
  exit 1
fi

# Check Profile file exists
if [ ! -f "$PROFILE_FILE" ]; then
  echo "❌ Error: Profile file not found at $PROFILE_FILE"
  exit 1
fi

# Get file stats
PROFILE_SIZE=$(stat -f%z "$PROFILE_FILE" 2>/dev/null || stat -c%s "$PROFILE_FILE" 2>/dev/null)
PROFILE_LINES=$(wc -l < "$PROFILE_FILE")

# Count profiles
PROFILE_COUNT=$(grep -c '<profile' "$PROFILE_FILE" || echo "0")
STANDARD_COUNT=$(grep -c 'isDefault="true"' "$PROFILE_FILE" || echo "0")
CUSTOM_COUNT=$((PROFILE_COUNT - STANDARD_COUNT))

echo "Validating Profile..."
echo "File: $PROFILE_FILE"
echo "Size: $PROFILE_SIZE bytes, $PROFILE_LINES lines"
echo "Profiles: $PROFILE_COUNT ($STANDARD_COUNT standard, $CUSTOM_COUNT custom)"
echo ""

# Run validation
if docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/docs/artifacts":/artifacts:ro \
  alpine:latest \
    sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/profiles.xsd /artifacts/profile.xml --noout; then

  echo ""
  echo "✓ Profile Validation Successful"
  echo "The Profile is ready to import into Bonita Studio."

  # Extract and list roles referenced
  echo ""
  echo "Roles referenced in profiles:"
  grep -o '<role>[^<]*</role>' "$PROFILE_FILE" | sed 's/<role>//;s/<\/role>//' | sort -u | sed 's/^/  - /'

  echo ""
  echo "Note: Ensure these roles exist in organization.xml"

  exit 0
else
  echo ""
  echo "✗ Profile Validation Failed"
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
chmod 644 "$PROFILE_FILE"
chmod 644 "$XSD_FILE"
```

### Schema Not Found

If XSD schema is missing:
```
Error: XSD schema not found at .claude/xsd/profiles.xsd
Solution: Ensure profiles.xsd is present in .claude/xsd/ directory
```

## Profile Statistics

After successful validation, report useful statistics:

```
Profile Generation Summary:
============================

Output File: docs/artifacts/profile.xml
File Size: 2,456 bytes

Profile Statistics:
- Total profiles: 5
- Standard profiles: 2
  - User
  - Administrator
- Custom profiles: 3
  - Demandeur
  - Valideur_RH
  - Valideur_CG

Mapping Statistics:
- Total role mappings: 6 unique roles
  - member (2 profiles)
  - demandeur (1 profile)
  - valideur_rh (1 profile)
  - admin_rh (2 profiles)
  - valideur_cg (1 profile)
- User mappings: 0
- Group mappings: 0
- Membership mappings: 0

Validation: ✓ PASSED
Status: Ready for import
```

## Next Steps

After successful validation:

1. **Import into Bonita Studio**
   - Use Organization → Import menu
   - Select the profile.xml file

2. **Verify in Bonita Portal**
   - Check Organization → Profiles
   - Verify all profiles are listed
   - Check profile mappings are correct

3. **Assign to Living Application**
   - In Bonita Portal, configure Living Application
   - Assign profiles to application pages/menus

4. **Test Access Control**
   - Log in as users with different roles
   - Verify correct profile access

5. **Coordinate with Other Artifacts**
   - Ensure organization.xml contains all referenced roles
   - Update process definitions to use correct actors
   - Configure application descriptors with profiles

## Common Validation Warnings

### Warning: Role Not Found

If a role referenced in profile doesn't exist in organization.xml:
```
Warning: Profile 'Valideur_RH' references role 'valideur_rh'
This role should exist in organization.xml

Action required:
- Verify role exists in organization.xml
- Or update profile to reference existing role
```

**Note**: This is a logical warning, not an XSD validation error. The XML is still valid.

### Warning: Empty Profile Mapping

If a profile has no mappings at all:
```
Warning: Profile 'Unused_Profile' has no mappings
This profile will not be assigned to any users

Action:
- Remove the profile if not needed
- Or add appropriate mappings
```

### Warning: Standard Profile Modified

If a standard profile has non-standard mappings:
```
Warning: Standard profile 'User' has custom mappings
Standard profiles should typically map to 'member' role

Review:
- Ensure this customization is intentional
- Consider using custom profile instead
```

## Validation Best Practices

1. **Always validate before import**
   - Catch errors early
   - Avoid import failures

2. **Review role references**
   - Cross-check with organization.xml
   - Ensure consistency

3. **Test with minimal set**
   - Start with essential profiles
   - Add more as needed

4. **Document custom profiles**
   - Clear descriptions
   - Document intended use

5. **Version control**
   - Track profile changes
   - Maintain history

6. **Coordinate with team**
   - Share profile definitions
   - Ensure consistent naming

## Exit Status Summary

| Code | Status | Meaning |
|------|--------|---------|
| 0 | Success | XML validates against schema |
| 1 | Error | Validation failed with errors |

Use exit code in scripts and CI/CD pipelines for automation.

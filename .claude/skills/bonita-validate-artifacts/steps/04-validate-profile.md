# Step 4: Validate Profiles

Validate the Profiles XML file (`profile.xml`) against the Bonita Profiles XSD schema.

## Input

- Target directory (from `--directory` parameter or default `docs/artifacts/`)
- XSD schema: `.claude/xsd/profiles.xsd`

## Process

1. Check if `profile.xml` exists in target directory
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
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/profiles.xsd /artifacts/profile.xml --noout
```

**Note**: Adjust volume mounts if using custom directory with `--directory` parameter.

## Expected Output

### On Success
```
/artifacts/profile.xml validates
```

### On Failure
xmllint will output detailed error messages showing:
- Line number of the error
- Element or attribute causing the issue
- Expected vs actual values

Example error:
```
/artifacts/profile.xml:12: element profile: Schemas validity error : Element 'profile',
attribute 'isDefault': 'yes' is not a valid value of the atomic type 'xs:boolean'.
```

## Error Interpretation

Common Profile validation errors:

### 1. Wrong Namespace
**Error**: `No matching global declaration available for the validation root`
**Cause**: Incorrect or missing namespace URI
**Solution**: Ensure root element has `xmlns="http://documentation.bonitasoft.com/profile-xml-schema/1.0"`

### 2. Invalid isDefault Value
**Error**: `attribute 'isDefault': 'X' is not a valid value of the atomic type 'xs:boolean'`
**Cause**: Using values other than "true" or "false"
**Solution**: Use `isDefault="true"` for standard Bonita profiles (User, Administrator) or `isDefault="false"` for custom profiles

### 3. Missing Profile Name
**Error**: `attribute 'name': The attribute 'name' is required but missing`
**Cause**: Profile element missing name attribute
**Solution**: Ensure all profiles have unique name attribute

### 4. Empty Profile Mappings
**Error**: `element profileMapping: validity error : Element 'profileMapping': Missing child element(s)`
**Cause**: profileMapping element has no users, groups, roles, or memberships
**Solution**: Add at least one mapping: `<users>`, `<groups>`, `<roles>`, or `<memberships>`

### 5. Duplicate Profile Names
**Error**: `Duplicate key-sequence ['profileName'] in unique identity-constraint`
**Cause**: Two or more profiles with the same name
**Solution**: Ensure all profile names are unique

### 6. Invalid Mapping Structure
**Error**: `This element is not expected. Expected is ( users | groups | roles | memberships )`
**Cause**: Invalid child elements in profileMapping
**Solution**: Use only: `<users>` (comma-separated usernames), `<groups>` (group paths), `<roles>` (role names), `<memberships>` (role/group pairs)

### 7. Missing Required Elements
**Error**: `element profiles: validity error : Element 'profiles': Missing child element(s)`
**Cause**: Empty profiles root or missing profile elements
**Solution**: Ensure profiles root contains at least one `<profile>` element

## Output for Report

Store validation result for summary report:
- **Status**: PASS or FAIL
- **File**: profile.xml
- **Size**: File size in bytes
- **Lines**: Line count
- **Error**: Full error message if failed

## Continue or Stop?

- If validation **succeeds**: Continue to Step 5
- If validation **fails**: Store error but continue to Step 5 (report all errors)
- If file **not found**: Log as optional and continue to Step 5

## Example

```bash
# Navigate to project root
cd /Users/laurentleseigneur/bonita/workspaces/2025.2-u2/poc-cnaf-rh2026

# Validate Profiles
docker pull alpine:latest

Then validate:

docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/[PATH]":/artifacts:ro \
  alpine:latest \
  sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint --schema /xsd/profiles.xsd /artifacts/profile.xml --noout

# Expected output on success:
# /artifacts/profile.xml validates
```

## Profile Structure Notes

A valid profile.xml must include:
1. **profiles** - Root element with namespace
2. **profile(s)** - One or more profile definitions with:
   - `name` attribute - Unique profile identifier
   - `isDefault` attribute - "true" for standard profiles, "false" for custom
3. **profileMapping** - For each profile, specifying access:
   - `<users>` - Comma-separated list of usernames (direct user assignment)
   - `<groups>` - Comma-separated list of group paths (e.g., "/acme")
   - `<roles>` - Comma-separated list of role names (e.g., "member")
   - `<memberships>` - Comma-separated role/group pairs (e.g., "member|/acme")

### Standard Profiles
- **User** - Default user profile (`isDefault="true"`)
- **Administrator** - Default admin profile (`isDefault="true"`)

### Custom Profiles
- Any custom profile name (`isDefault="false"`)
- Should map to specific roles/groups from organization

### Profile Mapping Examples

**Direct user assignment:**
```xml
<profileMapping>
  <users>walter.bates,helen.kelly</users>
</profileMapping>
```

**Group-based assignment:**
```xml
<profileMapping>
  <groups>/acme,/acme/hr</groups>
</profileMapping>
```

**Role-based assignment:**
```xml
<profileMapping>
  <roles>member,manager</roles>
</profileMapping>
```

**Membership-based assignment (role within group):**
```xml
<profileMapping>
  <memberships>member|/acme/hr,manager|/acme</memberships>
</profileMapping>
```

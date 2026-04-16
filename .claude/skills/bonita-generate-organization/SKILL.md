---
name: bonita-generate-organization
description: Generate Bonita Organization XML (users, roles, groups) from analysis document. Use when the user wants to generate, create, or build the organization, users, or groups XML artifact.
argument-hint: "[--input <analysis-file>] [--output <path>]"
allowed-tools: Read, Write, Bash, Glob, Grep
---

Generate a Bonita Organization XML file from an analysis document. The generated file contains users, roles, groups, and memberships validated against the XSD schema.

**CRITICAL** : read and apply `README_organization.md` before generation

## Usage

```bash
# Generate organization from default analysis document
/bonita-generate-organization

# Generate organization from specific analysis document
/bonita-generate-organization --input docs/out/analyse-project-2026-01-23.adoc

# Generate organization to custom output path
/bonita-generate-organization --input docs/out/analyse-project-2026-01-23.adoc --output custom/path/organization.xml
```

## Parameters

- `--input <path>` - Path to analysis document (default: most recent .adoc in `docs/out/`)
- `--output <path>` - Output path for organization file (default: `docs/artifacts/organization.xml`)

## Prerequisites

- Analysis document containing organization structure with actors, roles, groups
- Docker for XSD validation
- XSD schema at `.claude/xsd/organization.xsd`

## Global Directives

**IMPORTANT**: Use Docker for all tooling:
- First pull the Docker image: `docker pull alpine:latest`
- XML validation: `docker run --rm alpine:latest sh -c "apk add --no-cache libxml2-utils >/dev/null 2>&1 && xmllint ..."`

## Execution Steps

Follow these steps in order:

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--input`, `--output`) before starting.

### Step 1: Extract Organization Structure
[Read detailed instructions](steps/01-extract-org.md)
- Read analysis document (AsciiDoc format)
- Find organization/actors section
- Extract roles (process actors)
- Extract groups (organizational units, hierarchy)
- Extract users or create representative test users
- Map users to roles and groups (memberships)

### Step 2: Generate Organization XML
[Read detailed instructions](steps/02-generate-xml.md)
- Create XML with proper namespace
- Generate customUserInfoDefinitions section (optional custom fields)
- Generate users section with credentials
- Generate roles section
- Generate groups section with hierarchy
- Generate memberships section (user-role-group assignments)
- Save to output path

### Step 3: Validate Against XSD
[Read detailed instructions](steps/03-validate-xsd.md)
- Validate generated XML against `organization.xsd`
- Report validation results
- Display errors if validation fails

## Output

The skill generates **1 file**:

**`docs/artifacts/organization.xml`** - Bonita Organization XML containing:
- Users with credentials (test password: "bpm")
- Roles (process actors)
- Groups (organizational hierarchy)
- Memberships (user-to-role-to-group assignments)

## Organization Structure

### Users
Test users for demonstration/development:
- Username format: lowercase, dot-separated (e.g., "jean.dupont")
- Password: "bpm" (unencrypted for test purposes)
- Professional data: email, phone
- At least 1-2 users per role

### Roles
Business roles matching process actors:
- Role names: lowercase, underscore-separated (e.g., "valideur_rh")
- Display names: Human-readable (e.g., "Valideur RH")
- Descriptions explaining role purpose

### Groups
Organizational structure with hierarchy:
- Group names: lowercase, underscore-separated (e.g., "rh", "finance")
- Parent-child relationships via parentPath
- Example: `/cnaf/finance/budget` (budget group under finance under cnaf)

### Memberships
Assignments linking users to roles within groups:
- Each user assigned to at least one role/group combination
- Format: user + role + group + groupParentPath

## Critical Requirements

### 1. Proper Namespace

Root element must use:
```xml
<organization:Organization xmlns:organization="http://documentation.bonitasoft.com/organization-xml-schema/1.1">
```

### 2. Required Sections

All sections must be present (even if empty):
```xml
<customUserInfoDefinitions/>
<users>...</users>
<roles>...</roles>
<groups>...</groups>
<memberships>...</memberships>
```

### 3. Unique Identifiers

- **userName**: Must be unique across all users
- **role name**: Must be unique across all roles
- **group name + parentPath**: Must be unique across all groups

### 4. Valid Cross-References

All memberships must reference:
- Existing userName (from users section)
- Existing roleName (from roles section)
- Existing groupName + groupParentPath (from groups section)

### 5. Test Credentials

- Password: "bpm" (unencrypted)
- `encrypted="false"`
- All users enabled: `<enabled>true</enabled>`

## Example Organization Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<organization:Organization xmlns:organization="http://documentation.bonitasoft.com/organization-xml-schema/1.1">
  <customUserInfoDefinitions/>

  <users>
    <user userName="marie.martin">
      <firstName>Marie</firstName>
      <lastName>Martin</lastName>
      <title>Mrs</title>
      <jobTitle>Responsable RH</jobTitle>
      <professionalData>
        <email>marie.martin@company.com</email>
        <phoneNumber>+33 1 23 45 67 89</phoneNumber>
      </professionalData>
      <metaDatas/>
      <enabled>true</enabled>
      <password encrypted="false">bpm</password>
    </user>
  </users>

  <roles>
    <role name="valideur_rh">
      <displayName>Valideur RH</displayName>
      <description>Validateur du service Ressources Humaines</description>
    </role>
  </roles>

  <groups>
    <group name="acme">
      <displayName>ACME Corporation</displayName>
      <description>Root organization</description>
    </group>
    <group name="rh" parentPath="/acme">
      <displayName>Ressources Humaines</displayName>
      <description>Service RH</description>
    </group>
  </groups>

  <memberships>
    <membership>
      <userName>marie.martin</userName>
      <roleName>valideur_rh</roleName>
      <groupName>rh</groupName>
      <groupParentPath>/acme</groupParentPath>
    </membership>
  </memberships>
</organization:Organization>
```

## Group Hierarchy Examples

### Flat Structure
```xml
<group name="acme">...</group>
<group name="rh" parentPath="/acme">...</group>
<group name="finance" parentPath="/acme">...</group>
<group name="it" parentPath="/acme">...</group>
```

### Nested Structure
```xml
<group name="acme">...</group>
<group name="finance" parentPath="/acme">...</group>
<group name="budget" parentPath="/acme/finance">...</group>
<group name="control_gestion" parentPath="/acme/finance">...</group>
```

### Multiple Levels
```xml
<group name="acme">...</group>
<group name="directions" parentPath="/acme">...</group>
<group name="direction_nord" parentPath="/acme/directions">...</group>
<group name="direction_sud" parentPath="/acme/directions">...</group>
```

## User Examples

### Manager User
```xml
<user userName="jean.directeur">
  <firstName>Jean</firstName>
  <lastName>Directeur</lastName>
  <title>Mr</title>
  <jobTitle>Directeur Général</jobTitle>
  <professionalData>
    <email>jean.directeur@company.com</email>
    <phoneNumber>+33 1 23 45 67 89</phoneNumber>
  </professionalData>
  <metaDatas/>
  <enabled>true</enabled>
  <password encrypted="false">bpm</password>
</user>
```

### Employee User with Manager
```xml
<user userName="sophie.employee">
  <firstName>Sophie</firstName>
  <lastName>Employee</lastName>
  <title>Mrs</title>
  <jobTitle>Employee</jobTitle>
  <manager>jean.directeur</manager>
  <professionalData>
    <email>sophie.employee@company.com</email>
    <phoneNumber>+33 1 23 45 67 90</phoneNumber>
  </professionalData>
  <metaDatas/>
  <enabled>true</enabled>
  <password encrypted="false">bpm</password>
</user>
```

## Membership Examples

### Single Role Assignment
```xml
<membership>
  <userName>marie.martin</userName>
  <roleName>member</roleName>
  <groupName>rh</groupName>
  <groupParentPath>/acme</groupParentPath>
</membership>
```

### Multiple Roles for Same User
```xml
<membership>
  <userName>jean.directeur</userName>
  <roleName>member</roleName>
  <groupName>directions</groupName>
  <groupParentPath>/acme</groupParentPath>
</membership>
<membership>
  <userName>jean.directeur</userName>
  <roleName>manager</roleName>
  <groupName>directions</groupName>
  <groupParentPath>/acme</groupParentPath>
</membership>
```

### User in Multiple Groups
```xml
<membership>
  <userName>marie.martin</userName>
  <roleName>member</roleName>
  <groupName>rh</groupName>
  <groupParentPath>/acme</groupParentPath>
</membership>
<membership>
  <userName>marie.martin</userName>
  <roleName>member</roleName>
  <groupName>admin</groupName>
  <groupParentPath>/acme</groupParentPath>
</membership>
```

## Common Errors and Solutions

### Error: "Duplicate userName"
**Cause**: Two users with the same userName
**Solution**: Ensure all userNames are unique

### Error: "The key 'roleName' references a role that does not exist"
**Cause**: Membership references undefined role
**Solution**: Ensure role is defined in roles section

### Error: "No matching global declaration"
**Cause**: Wrong namespace
**Solution**: Use `http://documentation.bonitasoft.com/organization-xml-schema/1.1`

### Error: "Missing child element"
**Cause**: Required section missing
**Solution**: Include all required sections (even if empty): customUserInfoDefinitions, users, roles, groups, memberships

## Default Test Users

If analysis doesn't specify users, create representative test users:

**Admin user:**
- userName: "walter.bates"
- jobTitle: "Administrator"
- Role: "member" in root group

**Manager user:**
- userName: "helen.kelly"
- jobTitle: "Manager"
- Role: "manager" in relevant group

**Employee users:**
- Create 2-3 users per identified role
- userName pattern: firstname.lastname
- Assign to appropriate roles/groups

## Next Steps

After generating organization:
1. Review generated users, roles, groups
2. Import into Bonita Studio to test
3. Use with `/bonita-generate-bom` and `/bonita-generate-process` to create full application

## Notes

- Test password "bpm" is for development only
- Users should be updated with secure credentials in production
- Group hierarchy supports unlimited nesting levels
- Each user should have at least one membership
- Process actors should map to organization roles

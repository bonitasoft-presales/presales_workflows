# Step 2: Generate Organization XML

Generate the Bonita Organization XML file from extracted organization data.

## Input

- Extracted organization data from Step 1
- Output path (from `--output` parameter or default `docs/artifacts/organization.xml`)

## Process

1. Create output directory if needed
2. Generate XML structure with proper namespace
3. Generate customUserInfoDefinitions section (optional custom fields)
4. Generate users section with credentials
5. Generate roles section
6. Generate groups section with hierarchy
7. Generate memberships section
8. Write XML to file

## XML Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<organization:Organization xmlns:organization="http://documentation.bonitasoft.com/organization-xml-schema/1.1">
  <customUserInfoDefinitions/>
  <users>
    <!-- Users here -->
  </users>
  <roles>
    <!-- Roles here -->
  </roles>
  <groups>
    <!-- Groups here -->
  </groups>
  <memberships>
    <!-- Memberships here -->
  </memberships>
</organization:Organization>
```

## Creating Output Directory

```bash
# Ensure directory exists
mkdir -p "$(dirname "$output_path")"
```

## Section 1: Custom User Info Definitions

Optional section for custom user metadata fields.

**Empty (most common):**
```xml
<customUserInfoDefinitions/>
```

**With custom fields (optional):**
```xml
<customUserInfoDefinitions>
  <customUserInfoDefinition name="Badge Number">
    <description>Employee badge number</description>
  </customUserInfoDefinition>
  <customUserInfoDefinition name="Department Code">
    <description>Department code for employee</description>
  </customUserInfoDefinition>
</customUserInfoDefinitions>
```

For most cases, use empty `<customUserInfoDefinitions/>`.

## Section 2: Users

Generate user elements with full professional data.

### User Element Structure

```xml
<user userName="marie.martin">
  <firstName>Marie</firstName>
  <lastName>Martin</lastName>
  <title>Mrs</title>
  <jobTitle>Responsable RH</jobTitle>
  <manager>helen.kelly</manager>  <!-- Optional: userName of manager -->
  <professionalData>
    <email>marie.martin@cnaf.fr</email>
    <phoneNumber>+33 1 23 45 67 89</phoneNumber>
    <faxNumber></faxNumber>  <!-- Optional -->
    <building></building>  <!-- Optional -->
    <address></address>  <!-- Optional -->
    <zipCode></zipCode>  <!-- Optional -->
    <city></city>  <!-- Optional -->
    <state></state>  <!-- Optional -->
    <country></country>  <!-- Optional -->
  </professionalData>
  <metaDatas/>  <!-- Or <metaDatas> with metaData elements -->
  <enabled>true</enabled>
  <password encrypted="false">bpm</password>
</user>
```

### Required User Fields

**Always required:**
- `userName` - Unique identifier (lowercase.dot.separated)
- `firstName` - User's first name
- `lastName` - User's last name
- `title` - One of: "Mr", "Mrs", "Ms", "Miss"
- `jobTitle` - User's job title
- `professionalData/email` - Professional email
- `enabled` - Always "true" for test users
- `password` - Test password "bpm" with encrypted="false"

**Optional fields:**
- `manager` - userName of the user's manager
- `professionalData/phoneNumber` - Phone number
- `professionalData/faxNumber` - Fax number
- `professionalData/building` - Building number/name
- `professionalData/address` - Street address
- `professionalData/zipCode` - Postal code
- `professionalData/city` - City
- `professionalData/state` - State/region
- `professionalData/country` - Country

### Professional Data

**Minimal (recommended):**
```xml
<professionalData>
  <email>marie.martin@cnaf.fr</email>
  <phoneNumber>+33 1 23 45 67 89</phoneNumber>
</professionalData>
```

**Complete (optional):**
```xml
<professionalData>
  <email>marie.martin@cnaf.fr</email>
  <phoneNumber>+33 1 23 45 67 89</phoneNumber>
  <faxNumber>+33 1 23 45 67 00</faxNumber>
  <building>Building A</building>
  <address>10 Rue de la République</address>
  <zipCode>75001</zipCode>
  <city>Paris</city>
  <state>Île-de-France</state>
  <country>France</country>
</professionalData>
```

### MetaDatas Section

**Empty (most common):**
```xml
<metaDatas/>
```

**With metadata (optional):**
```xml
<metaDatas>
  <metaData name="Skype ID">marie.martin</metaData>
  <metaData name="Twitter">@mariemartin</metaData>
  <metaData name="Facebook">marie.martin</metaData>
</metaDatas>
```

For test users, use empty `<metaDatas/>`.

### Password Configuration

**Test/Development (always use this):**
```xml
<password encrypted="false">bpm</password>
```

**Never use encrypted passwords** in generated organization files. The password "bpm" is standard for test/development.

### Manager Hierarchy

If user has a manager:
```xml
<user userName="walter.bates">
  <firstName>Walter</firstName>
  <lastName>Bates</lastName>
  <title>Mr</title>
  <jobTitle>HR Specialist</jobTitle>
  <manager>helen.kelly</manager>  <!-- References another userName -->
  ...
</user>
```

The manager must be defined in the same users section.

### Complete User Examples

**Simple user:**
```xml
<user userName="marie.martin">
  <firstName>Marie</firstName>
  <lastName>Martin</lastName>
  <title>Mrs</title>
  <jobTitle>Responsable RH</jobTitle>
  <professionalData>
    <email>marie.martin@cnaf.fr</email>
    <phoneNumber>+33 1 23 45 67 89</phoneNumber>
  </professionalData>
  <metaDatas/>
  <enabled>true</enabled>
  <password encrypted="false">bpm</password>
</user>
```

**User with manager:**
```xml
<user userName="walter.bates">
  <firstName>Walter</firstName>
  <lastName>Bates</lastName>
  <title>Mr</title>
  <jobTitle>HR Specialist</jobTitle>
  <manager>marie.martin</manager>
  <professionalData>
    <email>walter.bates@cnaf.fr</email>
    <phoneNumber>+33 1 23 45 67 90</phoneNumber>
  </professionalData>
  <metaDatas/>
  <enabled>true</enabled>
  <password encrypted="false">bpm</password>
</user>
```

## Section 3: Roles

Generate role elements with display names and descriptions.

### Role Element Structure

```xml
<role name="valideur_rh">
  <displayName>Valideur RH</displayName>
  <description>Validateur du service Ressources Humaines</description>
</role>
```

### Required Role Fields

- `name` - Unique role identifier (lowercase_underscore_separated)
- `displayName` - Human-readable name (proper case)
- `description` - Clear description of role purpose

### Role Naming Conventions

**Name format:**
- lowercase
- underscore-separated words
- No spaces, special characters
- Examples: "valideur_rh", "admin_rh", "member", "manager"

**DisplayName format:**
- Proper case
- Human-readable
- Can include spaces, accents
- Examples: "Valideur RH", "Admin RH", "Member", "Manager"

### Standard Roles

**Basic roles (always useful):**
```xml
<role name="member">
  <displayName>Member</displayName>
  <description>General member role</description>
</role>

<role name="manager">
  <displayName>Manager</displayName>
  <description>Manager role</description>
</role>

<role name="admin">
  <displayName>Administrator</displayName>
  <description>Administrator role</description>
</role>
```

### Business-Specific Roles

**HR domain:**
```xml
<role name="demandeur">
  <displayName>Demandeur</displayName>
  <description>Employee initiating recruitment requests</description>
</role>

<role name="valideur_rh">
  <displayName>Valideur RH</displayName>
  <description>HR validator who reviews requests</description>
</role>

<role name="admin_rh">
  <displayName>Admin RH</displayName>
  <description>HR administrator managing the process</description>
</role>
```

**Financial domain:**
```xml
<role name="valideur_budget">
  <displayName>Valideur Budget</displayName>
  <description>Budget validator approving funding</description>
</role>

<role name="valideur_cg">
  <displayName>Valideur Contrôle Gestion</displayName>
  <description>Control and management validator</description>
</role>
```

### Multiple Roles Example

```xml
<roles>
  <role name="member">
    <displayName>Member</displayName>
    <description>General member role</description>
  </role>
  <role name="manager">
    <displayName>Manager</displayName>
    <description>Manager role</description>
  </role>
  <role name="demandeur">
    <displayName>Demandeur</displayName>
    <description>Employee initiating recruitment requests</description>
  </role>
  <role name="valideur_rh">
    <displayName>Valideur RH</displayName>
    <description>HR validator who reviews requests</description>
  </role>
  <role name="valideur_cg">
    <displayName>Valideur Contrôle Gestion</displayName>
    <description>Control and management validator</description>
  </role>
  <role name="valideur_budget">
    <displayName>Valideur Budget</displayName>
    <description>Budget validator approving funding</description>
  </role>
  <role name="admin_rh">
    <displayName>Admin RH</displayName>
    <description>HR administrator managing the process</description>
  </role>
</roles>
```

## Section 4: Groups

Generate group elements with hierarchical structure.

### Group Element Structure

**Root group (no parent):**
```xml
<group name="cnaf">
  <displayName>CNAF</displayName>
  <description>Caisse Nationale des Allocations Familiales</description>
</group>
```

**Child group (with parent):**
```xml
<group name="rh" parentPath="/cnaf">
  <displayName>Ressources Humaines</displayName>
  <description>Service RH de la CNAF</description>
</group>
```

**Nested child group:**
```xml
<group name="control_gestion" parentPath="/cnaf/finance">
  <displayName>Contrôle Gestion</displayName>
  <description>Service de Contrôle de Gestion</description>
</group>
```

### Required Group Fields

- `name` - Unique group identifier (lowercase_underscore_separated)
- `displayName` - Human-readable name (proper case)
- `description` - Clear description of group purpose
- `parentPath` - Path to parent group (attribute, required for child groups)

### Group Naming Conventions

**Name format:**
- lowercase
- underscore-separated words
- No spaces, special characters
- Examples: "cnaf", "rh", "control_gestion", "direction_nord"

**DisplayName format:**
- Proper case
- Human-readable
- Can include spaces, accents
- Examples: "CNAF", "Ressources Humaines", "Contrôle Gestion"

### Parent Path Rules

**Root group:**
- No `parentPath` attribute
- Example: `<group name="cnaf">`

**First-level child:**
- `parentPath="/parent"`
- Example: `<group name="rh" parentPath="/cnaf">`

**Nested child:**
- `parentPath="/parent/child"`
- Example: `<group name="budget" parentPath="/cnaf/finance">`

**Path format:**
- Always starts with `/`
- Separates hierarchy levels with `/`
- Uses group names (not displayNames)
- Example paths: "/cnaf", "/cnaf/finance", "/cnaf/finance/budget"

### Group Hierarchy Examples

**Flat structure:**
```xml
<groups>
  <group name="acme">
    <displayName>ACME Corporation</displayName>
    <description>Root organization</description>
  </group>
  <group name="rh" parentPath="/acme">
    <displayName>Ressources Humaines</displayName>
    <description>HR department</description>
  </group>
  <group name="finance" parentPath="/acme">
    <displayName>Finance</displayName>
    <description>Finance department</description>
  </group>
  <group name="it" parentPath="/acme">
    <displayName>IT</displayName>
    <description>IT department</description>
  </group>
</groups>
```

**Nested structure:**
```xml
<groups>
  <group name="cnaf">
    <displayName>CNAF</displayName>
    <description>Caisse Nationale des Allocations Familiales</description>
  </group>
  <group name="finance" parentPath="/cnaf">
    <displayName>Finance</displayName>
    <description>Service Financier</description>
  </group>
  <group name="control_gestion" parentPath="/cnaf/finance">
    <displayName>Contrôle Gestion</displayName>
    <description>Service de Contrôle de Gestion</description>
  </group>
  <group name="budget" parentPath="/cnaf/finance">
    <displayName>Budget</displayName>
    <description>Service Budget</description>
  </group>
</groups>
```

**Multiple levels:**
```xml
<groups>
  <group name="cnaf">
    <displayName>CNAF</displayName>
    <description>Root organization</description>
  </group>
  <group name="directions" parentPath="/cnaf">
    <displayName>Directions</displayName>
    <description>Operational directions</description>
  </group>
  <group name="direction_nord" parentPath="/cnaf/directions">
    <displayName>Direction Nord</displayName>
    <description>Northern region direction</description>
  </group>
  <group name="direction_sud" parentPath="/cnaf/directions">
    <displayName>Direction Sud</displayName>
    <description>Southern region direction</description>
  </group>
  <group name="direction_est" parentPath="/cnaf/directions">
    <displayName>Direction Est</displayName>
    <description>Eastern region direction</description>
  </group>
</groups>
```

### Group Order in XML

**IMPORTANT:** Define parent groups before child groups:

```xml
<!-- Correct order -->
<group name="cnaf">...</group>
<group name="finance" parentPath="/cnaf">...</group>
<group name="budget" parentPath="/cnaf/finance">...</group>

<!-- Wrong order (budget before finance) -->
<group name="cnaf">...</group>
<group name="budget" parentPath="/cnaf/finance">...</group>  <!-- ERROR: parent not yet defined -->
<group name="finance" parentPath="/cnaf">...</group>
```

## Section 5: Memberships

Generate membership elements linking users to roles within groups.

### Membership Element Structure

```xml
<membership>
  <userName>marie.martin</userName>
  <roleName>valideur_rh</roleName>
  <groupName>rh</groupName>
  <groupParentPath>/cnaf</groupParentPath>
</membership>
```

### Required Membership Fields

- `userName` - Must match an existing user
- `roleName` - Must match an existing role
- `groupName` - Group name (not displayName)
- `groupParentPath` - Parent path of the group (or "/" for root group)

### Cross-Reference Rules

**userName must exist in users section:**
```xml
<users>
  <user userName="marie.martin">...</user>
</users>
<memberships>
  <membership>
    <userName>marie.martin</userName>  <!-- Must match user above -->
    ...
  </membership>
</memberships>
```

**roleName must exist in roles section:**
```xml
<roles>
  <role name="valideur_rh">...</role>
</roles>
<memberships>
  <membership>
    <roleName>valideur_rh</roleName>  <!-- Must match role above -->
    ...
  </membership>
</memberships>
```

**groupName + groupParentPath must match a group:**
```xml
<groups>
  <group name="rh" parentPath="/cnaf">...</group>
</groups>
<memberships>
  <membership>
    <groupName>rh</groupName>
    <groupParentPath>/cnaf</groupParentPath>  <!-- Together must match group above -->
  </membership>
</memberships>
```

### Group Parent Path for Memberships

**For root group:**
```xml
<group name="cnaf">...</group>

<membership>
  <groupName>cnaf</groupName>
  <groupParentPath>/</groupParentPath>  <!-- Root group uses "/" -->
</membership>
```

**For child group:**
```xml
<group name="rh" parentPath="/cnaf">...</group>

<membership>
  <groupName>rh</groupName>
  <groupParentPath>/cnaf</groupParentPath>  <!-- Use the parent path from group -->
</membership>
```

**For nested child group:**
```xml
<group name="budget" parentPath="/cnaf/finance">...</group>

<membership>
  <groupName>budget</groupName>
  <groupParentPath>/cnaf/finance</groupParentPath>  <!-- Use the parent path from group -->
</membership>
```

### Single Membership Example

```xml
<membership>
  <userName>marie.martin</userName>
  <roleName>valideur_rh</roleName>
  <groupName>rh</groupName>
  <groupParentPath>/cnaf</groupParentPath>
</membership>
```

### Multiple Memberships for Same User

A user can have multiple roles:
```xml
<membership>
  <userName>marie.martin</userName>
  <roleName>member</roleName>
  <groupName>rh</groupName>
  <groupParentPath>/cnaf</groupParentPath>
</membership>
<membership>
  <userName>marie.martin</userName>
  <roleName>valideur_rh</roleName>
  <groupName>rh</groupName>
  <groupParentPath>/cnaf</groupParentPath>
</membership>
```

A user can belong to multiple groups:
```xml
<membership>
  <userName>jean.dupont</userName>
  <roleName>member</roleName>
  <groupName>control_gestion</groupName>
  <groupParentPath>/cnaf/finance</groupParentPath>
</membership>
<membership>
  <userName>jean.dupont</userName>
  <roleName>valideur_cg</roleName>
  <groupName>finance</groupName>
  <groupParentPath>/cnaf</groupParentPath>
</membership>
```

### Multiple Memberships Example

```xml
<memberships>
  <membership>
    <userName>marie.martin</userName>
    <roleName>valideur_rh</roleName>
    <groupName>rh</groupName>
    <groupParentPath>/cnaf</groupParentPath>
  </membership>
  <membership>
    <userName>pierre.durand</userName>
    <roleName>valideur_rh</roleName>
    <groupName>rh</groupName>
    <groupParentPath>/cnaf</groupParentPath>
  </membership>
  <membership>
    <userName>jean.dupont</userName>
    <roleName>valideur_cg</roleName>
    <groupName>control_gestion</groupName>
    <groupParentPath>/cnaf/finance</groupParentPath>
  </membership>
  <membership>
    <userName>sophie.bernard</userName>
    <roleName>valideur_budget</roleName>
    <groupName>budget</groupName>
    <groupParentPath>/cnaf/finance</groupParentPath>
  </membership>
  <membership>
    <userName>luc.moreau</userName>
    <roleName>member</roleName>
    <groupName>directions</groupName>
    <groupParentPath>/cnaf</groupParentPath>
  </membership>
</memberships>
```

## Complete Organization XML Example

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
        <email>marie.martin@cnaf.fr</email>
        <phoneNumber>+33 1 23 45 67 89</phoneNumber>
      </professionalData>
      <metaDatas/>
      <enabled>true</enabled>
      <password encrypted="false">bpm</password>
    </user>
    <user userName="jean.dupont">
      <firstName>Jean</firstName>
      <lastName>Dupont</lastName>
      <title>Mr</title>
      <jobTitle>Contrôleur de Gestion</jobTitle>
      <professionalData>
        <email>jean.dupont@cnaf.fr</email>
        <phoneNumber>+33 1 23 45 67 91</phoneNumber>
      </professionalData>
      <metaDatas/>
      <enabled>true</enabled>
      <password encrypted="false">bpm</password>
    </user>
  </users>

  <roles>
    <role name="member">
      <displayName>Member</displayName>
      <description>General member role</description>
    </role>
    <role name="valideur_rh">
      <displayName>Valideur RH</displayName>
      <description>HR validator who reviews requests</description>
    </role>
    <role name="valideur_cg">
      <displayName>Valideur Contrôle Gestion</displayName>
      <description>Control and management validator</description>
    </role>
  </roles>

  <groups>
    <group name="cnaf">
      <displayName>CNAF</displayName>
      <description>Caisse Nationale des Allocations Familiales</description>
    </group>
    <group name="rh" parentPath="/cnaf">
      <displayName>Ressources Humaines</displayName>
      <description>Service RH de la CNAF</description>
    </group>
    <group name="finance" parentPath="/cnaf">
      <displayName>Finance</displayName>
      <description>Service Financier</description>
    </group>
    <group name="control_gestion" parentPath="/cnaf/finance">
      <displayName>Contrôle Gestion</displayName>
      <description>Service de Contrôle de Gestion</description>
    </group>
  </groups>

  <memberships>
    <membership>
      <userName>marie.martin</userName>
      <roleName>valideur_rh</roleName>
      <groupName>rh</groupName>
      <groupParentPath>/cnaf</groupParentPath>
    </membership>
    <membership>
      <userName>jean.dupont</userName>
      <roleName>valideur_cg</roleName>
      <groupName>control_gestion</groupName>
      <groupParentPath>/cnaf/finance</groupParentPath>
    </membership>
  </memberships>
</organization:Organization>
```

## Writing XML File

1. Format XML with proper indentation (2 spaces recommended)
2. Use UTF-8 encoding
3. Include XML declaration: `<?xml version="1.0" encoding="UTF-8"?>`
4. Ensure all tags are properly closed
5. Write to output path

```bash
# Create directory if needed
mkdir -p "$(dirname "$OUTPUT_PATH")"

# Write XML content to file
cat > "$OUTPUT_PATH" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<organization:Organization xmlns:organization="http://documentation.bonitasoft.com/organization-xml-schema/1.1">
  ...
</organization:Organization>
EOF
```

## Verification Before Step 3

Before proceeding to validation:
- ✅ File created at correct path
- ✅ XML is well-formed
- ✅ Proper namespace declared
- ✅ All required sections present (even if empty)
- ✅ All userNames are unique
- ✅ All role names are unique
- ✅ All group name+parentPath combinations are unique
- ✅ All memberships reference existing users, roles, and groups
- ✅ Parent groups defined before child groups
- ✅ Each user has at least one membership
- ✅ All passwords use encrypted="false" with value "bpm"

## Output

- Organization XML file saved to specified path
- File path and size reported
- Ready for XSD validation in Step 3

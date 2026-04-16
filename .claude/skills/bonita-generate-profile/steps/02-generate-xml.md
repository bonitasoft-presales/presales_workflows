# Step 2: Generate Profile XML

Generate the Bonita Profile XML file from extracted profile data.

## Input

- Extracted profile data from Step 1
- Output path (from `--output` parameter or default `docs/artifacts/profile.xml`)

## Process

1. Create output directory if needed
2. Generate XML structure with proper namespace
3. For each profile, generate profile element
4. Add profile mappings to roles, users, groups, or memberships
5. Write XML to file

## XML Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<profiles:profiles xmlns:profiles="http://documentation.bonitasoft.com/profile-xml-schema/1.0">
  <!-- Profile elements here -->
</profiles:profiles>
```

## Creating Output Directory

```bash
# Ensure directory exists
mkdir -p "$(dirname "$output_path")"
```

## Generating Profile Elements

For each profile from Step 1:

### 1. Profile Element Structure

```xml
<profile isDefault="false" name="ProfileName">
  <description>Profile description</description>
  <profileMapping>
    <users/>
    <groups/>
    <memberships/>
    <roles/>
  </profileMapping>
</profile>
```

**Attributes:**
- `isDefault` - "true" for standard Bonita profiles, "false" for custom
- `name` - Profile name (alphanumeric and underscore only)

**Required elements:**
- `description` - Profile description text
- `profileMapping` - Contains mapping elements

### 2. IMPORTANT: No Default Profiles

**DO NOT GENERATE** these profiles (they already exist in default_profile.xml):
- User (isDefault="true")
- Administrator (isDefault="true")
- Process manager (isDefault="true")

These will be deployed separately from default_profile.xml.

### 3. Custom Application Profiles ONLY

For custom profiles (isDefault="false"):

#### Single Role Mapping
```xml
<profile isDefault="false" name="Demandeur">
  <description>Profile pour les demandeurs (Directions et Assistantes de direction)</description>
  <profileMapping>
    <users/>
    <groups/>
    <memberships/>
    <roles>
      <role>demandeur</role>
    </roles>
  </profileMapping>
</profile>
```

#### Multiple Role Mapping
```xml
<profile isDefault="false" name="Valideur_RH">
  <description>Profile pour les validateurs du service RH</description>
  <profileMapping>
    <users/>
    <groups/>
    <memberships/>
    <roles>
      <role>valideur_rh</role>
      <role>admin_rh</role>
    </roles>
  </profileMapping>
</profile>
```

### 4. ProfileMapping Element

The profileMapping element always contains four sub-elements (can be empty):

```xml
<profileMapping>
  <users>
    <!-- User elements or empty -->
  </users>
  <groups>
    <!-- Group elements or empty -->
  </groups>
  <memberships>
    <!-- Membership elements or empty -->
  </memberships>
  <roles>
    <!-- Role elements or empty -->
  </roles>
</profileMapping>
```

**IMPORTANT**: All four elements must be present, even if empty.

### 5. Mapping Types

#### Role Mapping (Recommended)

Map profile to one or more organizational roles:

```xml
<roles>
  <role>demandeur</role>
  <role>valideur_rh</role>
  <role>admin_rh</role>
</roles>
```

**When to use:**
- Most flexible and maintainable approach
- Aligns with standard Bonita architecture
- Easier to manage in Bonita Portal
- Recommended for most cases

#### User Mapping

Map profile to specific users by username:

```xml
<users>
  <user>walter.bates</user>
  <user>helen.kelly</user>
  <user>john.doe</user>
</users>
```

**When to use:**
- Very specific access requirements
- Temporary access grants
- Small number of users
- Quick prototyping

#### Group Mapping

Map profile to organizational groups by path:

```xml
<groups>
  <group>/Acme</group>
  <group>/Acme/HR</group>
  <group>/Acme/Finance/Budget</group>
</groups>
```

**When to use:**
- All members of a group need same access
- Group-based access control
- Organizational structure mirrors access needs

**Group path format:**
- Must start with `/`
- Use `/` separator for hierarchy
- Example: `/CompanyName/Department/Team`

#### Membership Mapping

Map profile to role+group combinations:

```xml
<memberships>
  <membership>manager|/Acme/HR</membership>
  <membership>employee|/Acme/HR</membership>
  <membership>admin|/Acme</membership>
</memberships>
```

**When to use:**
- Need specific role within specific group
- Fine-grained access control
- Complex organizational structures

**Membership format:**
- Pattern: `roleName|groupPath`
- Example: `manager|/Acme/HR` means "manager role in HR group"

### 6. Empty Mapping Elements

When a mapping type is not used, include empty element:

```xml
<!-- No users mapped -->
<users/>

<!-- No groups mapped -->
<groups/>

<!-- No memberships mapped -->
<memberships/>

<!-- No roles mapped -->
<roles/>
```

**IMPORTANT**: Empty elements are required. Do not omit them.

## Profile Ordering

Organize CUSTOM profiles in logical order:

1. **Custom profiles by hierarchy** (if applicable)
   - Admin profiles
   - Manager profiles
   - User profiles

2. **Custom profiles alphabetically** (if no hierarchy)

**IMPORTANT**: Standard Bonita profiles (User, Administrator, Process manager) are NOT included in CNAF_profiles.xml.

Example order (CUSTOM PROFILES ONLY):
```xml
<profiles:profiles ...>
  <!-- Custom admin profiles first -->
  <profile isDefault="false" name="Administrateur_Systeme">...</profile>

  <!-- Custom user profiles alphabetically -->
  <profile isDefault="false" name="Demandeur">...</profile>
  <profile isDefault="false" name="Lecteur">...</profile>
  <profile isDefault="false" name="Valideur_Budget">...</profile>
  <profile isDefault="false" name="Valideur_Controle_Gestion">...</profile>
  <profile isDefault="false" name="Valideur_RH">...</profile>
</profiles:profiles>
```

## Complete Profile Example (CUSTOM PROFILES ONLY)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<profiles:profiles xmlns:profiles="http://documentation.bonitasoft.com/profile-xml-schema/1.0">
  <!-- NOTE: Standard Bonita profiles (User, Administrator, Process manager) are NOT included -->
  <!-- They already exist in default_profile.xml and are deployed separately -->

  <!-- Custom Application Profiles -->
  <profile isDefault="false" name="Administrateur_Systeme">
    <description>Administrateurs du système avec accès complet à l'application</description>
    <profileMapping>
      <users>
        <user>walter.bates</user>
      </users>
      <groups/>
      <memberships/>
      <roles>
        <role>administrateur</role>
      </roles>
    </profileMapping>
  </profile>

  <profile isDefault="false" name="Initiateur">
    <description>Profile pour les initiateurs - Directions et Assistantes de direction</description>
    <profileMapping>
      <users/>
      <groups/>
      <memberships/>
      <roles>
        <role>initiateur</role>
      </roles>
    </profileMapping>
  </profile>

  <profile isDefault="false" name="Valideur_RH">
    <description>Profile pour les validateurs du service Ressources Humaines</description>
    <profileMapping>
      <users/>
      <groups/>
      <memberships/>
      <roles>
        <role>valideur_rh</role>
        <role>valideur_final_rh</role>
      </roles>
    </profileMapping>
  </profile>

  <profile isDefault="false" name="Valideur_Controle_Gestion">
    <description>Profile pour les validateurs du Contrôle de Gestion</description>
    <profileMapping>
      <users/>
      <groups/>
      <memberships/>
      <roles>
        <role>valideur_controle_gestion</role>
      </roles>
    </profileMapping>
  </profile>

  <profile isDefault="false" name="Valideur_Budget">
    <description>Profile pour les validateurs du service Budget</description>
    <profileMapping>
      <users/>
      <groups/>
      <memberships/>
      <roles>
        <role>valideur_budget</role>
      </roles>
    </profileMapping>
  </profile>

  <profile isDefault="false" name="Lecteur">
    <description>Profile pour la consultation des demandes en lecture seule</description>
    <profileMapping>
      <users/>
      <groups/>
      <memberships/>
      <roles>
        <role>lecteur</role>
      </roles>
    </profileMapping>
  </profile>
</profiles:profiles>
```

**IMPORTANT NOTES**:
- All profiles have `isDefault="false"` (custom profiles only)
- Walter Bates is added to Administrateur_Systeme profile (Bonita Studio requirement)
- No default Bonita profiles included - they're in default_profile.xml

## Writing XML File

1. Format XML with proper indentation (2 or 4 spaces)
2. Use UTF-8 encoding
3. Include XML declaration: `<?xml version="1.0" encoding="UTF-8"?>`
4. Include proper namespace
5. Ensure all tags are properly closed
6. Write to output path

```bash
# Create directory if needed
mkdir -p "$(dirname "$OUTPUT_PATH")"

# Write XML content to file
cat > "$OUTPUT_PATH" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<profiles:profiles xmlns:profiles="http://documentation.bonitasoft.com/profile-xml-schema/1.0">
  ...
</profiles:profiles>
EOF
```

## Special Characters in Descriptions

Handle special characters properly:

### XML Special Characters
Escape these in descriptions:
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`
- `"` → `&quot;`
- `'` → `&apos;`

### Accented Characters
Use UTF-8 encoding to preserve:
- `é`, `è`, `ê`, `ë`
- `à`, `â`
- `ù`, `û`
- `ç`
- `ï`, `î`

Example:
```xml
<description>Profile pour les validateurs du Contrôle de Gestion</description>
```

## Validation Before Step 3

Before proceeding to validation:
- ✅ File created at correct path
- ✅ XML is well-formed
- ✅ Proper namespace and encoding
- ✅ All profiles included
- ✅ Standard profiles have exact names and descriptions
- ✅ All profileMapping elements have four sub-elements
- ✅ Empty elements use self-closing tags (`<users/>`)
- ✅ Role references match organization roles (informational check)

## Common Generation Mistakes to Avoid

### ❌ Missing Empty Elements
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

### ❌ Wrong Namespace
```xml
<!-- Wrong namespace -->
<profiles xmlns="http://...">

<!-- Correct namespace with prefix -->
<profiles:profiles xmlns:profiles="http://documentation.bonitasoft.com/profile-xml-schema/1.0">
```

### ❌ Invalid Profile Names
```xml
<!-- Wrong - contains space -->
<profile name="Valideur RH">

<!-- Correct - uses underscore -->
<profile name="Valideur_RH">
```

### ❌ Modified Standard Profile Description
```xml
<!-- Wrong - modified description -->
<profile isDefault="true" name="User">
  <description>Standard user profile</description>

<!-- Correct - exact description -->
<profile isDefault="true" name="User">
  <description>This is a default profile. Name and description will be translated in Bonita Portal. Do not edit the name or the description.</description>
```

### ❌ Empty Role Element
```xml
<!-- Wrong - empty role element -->
<roles>
  <role></role>
</roles>

<!-- Correct - remove empty role or provide value -->
<roles>
  <role>demandeur</role>
</roles>
```

## Output

- Profile XML file saved to specified path
- File path and size reported
- Number of profiles generated
- Ready for XSD validation in Step 3

## Summary Statistics

Report generation summary:
```
Profile XML Generated:
- File: docs/artifacts/profile.xml
- Size: 2,456 bytes
- Total profiles: 5
  - Standard profiles: 2 (User, Administrator)
  - Custom profiles: 3 (Demandeur, Valideur_RH, Valideur_CG)
- Total role mappings: 6
- Ready for validation
```

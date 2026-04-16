---
name: bonita-generate-profile
description: Generate Bonita Profile XML (access control) from analysis document. Use when the user wants to generate, create, or build profiles or access control XML for the application.
argument-hint: "[--input <analysis-file>] [--output <path>]"
allowed-tools: Read, Write, Bash, Glob, Grep
---

Generate a Bonita Profile XML file from an analysis document. The generated file conforms to Bonita 10.x format and is validated against the XSD schema.

**CRITICAL** : read and apply `README_profile.md` before generation

**IMPORTANT**: Default Bonita profiles (User, Administrator, Process manager) already exist in `app/profiles/default_profile.xml` and MUST NOT be generated in CNAF_profiles.xml. Only generate CUSTOM application-specific profiles.

## Usage

```bash
# Generate Profile from default analysis document
/bonita-generate-profile

# Generate Profile from specific analysis document
/bonita-generate-profile --input docs/out/analyse-project-2026-01-23.adoc

# Generate Profile to custom output path
/bonita-generate-profile --input docs/out/analyse-project-2026-01-23.adoc --output custom/path/profile.xml
```

## Parameters

- `--input <path>` - Path to analysis document (default: most recent .adoc in `docs/out/`)
- `--output <path>` - Output path for Profile file (default: `docs/artifacts/profile.xml`)

## Prerequisites

- Analysis document containing actors/roles section with profile definitions
- Docker for XSD validation
- XSD schema at `.claude/xsd/profiles.xsd`

## Global Directives

**IMPORTANT**: Use Docker for all tooling:
- XML validation: `docker run --rm alpine:latest sh -c "apk add --no-cache libxml2-utils >/dev/null 2&1 && xmllint ...`
- Python scripts: `docker run --rm python:3 python3 -c "..."`

## Execution Steps

Follow these steps in order:

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--input`, `--output`) before starting.

### Step 1: Extract Profiles
[Read detailed instructions](steps/01-extract-profiles.md)
- Read analysis document (AsciiDoc format)
- Find Actors/Roles/Profiles section
- Extract actor definitions with roles and access requirements
- Identify profile mappings (users, groups, roles, memberships)
- Determine default Bonita profiles to include

### Step 2: Generate Profile XML
[Read detailed instructions](steps/02-generate-xml.md)
- Create XML with proper namespace and structure
- Generate profile elements for each actor type
- Add profile mappings to organizational roles
- Include standard Bonita profiles if needed
- Save to output path

### Step 3: Validate Against XSD
[Read detailed instructions](steps/03-validate-xsd.md)
- Validate generated XML against `profiles.xsd`
- Report validation results
- Display errors if validation fails

## Output

The skill generates **1 file**:

**`docs/artifacts/profile.xml`** - Bonita Profile XML containing:
- Custom profile definitions for application actors ONLY
- Profile mappings to organizational roles
- EXCLUDES standard Bonita profiles (User, Administrator, Process manager) which exist in default_profile.xml

## Profile Structure

### Profile Element

Each profile contains:
- `name` - Profile name (alphanumeric, no spaces)
- `description` - Clear description of profile purpose
- `isDefault` - "true" for standard Bonita profiles, "false" for custom
- `profileMapping` - Maps profile to users, groups, roles, or memberships

### Profile Mapping

Profiles can be mapped to:
- **Roles**: Most flexible approach (recommended)
- **Users**: Specific usernames
- **Groups**: Group paths (e.g., "/Acme/HR")
- **Memberships**: Role+Group combinations (e.g., "manager|/Acme/HR")

**Best Practice**: Map profiles to roles for flexibility and maintainability.

## Standard Bonita Profiles (EXCLUDED)

**DO NOT GENERATE** these profiles in CNAF_profiles.xml:

### User, Administrator, Process Manager
These profiles already exist in `app/profiles/default_profile.xml`:
- **User** (isDefault="true") - Standard user profile
- **Administrator** (isDefault="true") - System administrator profile
- **Process manager** (isDefault="true") - Process management profile

**IMPORTANT**: These default profiles are deployed separately from default_profile.xml. The generated CNAF_profiles.xml should ONLY contain custom application-specific profiles.

## Custom Profile Examples

### Single Role Mapping
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

### Multiple Role Mapping
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

### User-Specific Mapping
```xml
<profile isDefault="false" name="Admin_System">
  <description>System administrators</description>
  <profileMapping>
    <users>
      <user>walter.bates</user>
      <user>helen.kelly</user>
    </users>
    <groups/>
    <memberships/>
    <roles/>
  </profileMapping>
</profile>
```

### Group Mapping
```xml
<profile isDefault="false" name="HR_Department">
  <description>All HR department members</description>
  <profileMapping>
    <users/>
    <groups>
      <group>/Acme/HR</group>
    </groups>
    <memberships/>
    <roles/>
  </profileMapping>
</profile>
```

### Membership Mapping
```xml
<profile isDefault="false" name="HR_Managers">
  <description>HR department managers only</description>
  <profileMapping>
    <users/>
    <groups/>
    <memberships>
      <membership>manager|/Acme/HR</membership>
    </memberships>
    <roles/>
  </profileMapping>
</profile>
```

## Naming Conventions

### Profile Names
- Use alphanumeric characters and underscores
- No spaces (use underscore instead)
- Examples: `Demandeur`, `Valideur_RH`, `Admin_System`

### Role References
- Must match roles defined in organization.xml
- Case-sensitive
- Examples: `demandeur`, `valideur_rh`, `admin_rh`, `member`

## Complete Example (CUSTOM PROFILES ONLY)

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

## Common Errors and Solutions

### Error: "No matching global declaration available"
**Cause**: Incorrect or missing namespace URI

**Solution**: Ensure root element has correct namespace:
```xml
<profiles:profiles xmlns:profiles="http://documentation.bonitasoft.com/profile-xml-schema/1.0">
```

### Error: "Element 'profile': Missing child element(s)"
**Cause**: Missing required elements (description or profileMapping)

**Solution**: Include all required elements:
```xml
<profile isDefault="false" name="ProfileName">
  <description>Description here</description>
  <profileMapping>
    <users/>
    <groups/>
    <memberships/>
    <roles/>
  </profileMapping>
</profile>
```

### Error: "Attribute 'isDefault': Value not valid"
**Cause**: Using invalid value for isDefault

**Solution**: Use only "true" or "false":
```xml
<profile isDefault="false" name="ProfileName">
```

### Error: "Element 'role': Character content is not allowed"
**Cause**: Empty role element or invalid content

**Solution**: Each role element must contain a valid role name:
```xml
<roles>
  <role>demandeur</role>
  <role>valideur_rh</role>
</roles>
```

### Warning: "Profile name contains spaces"
**Cause**: Profile names should not contain spaces

**Solution**: Use underscores or camelCase:
```xml
<!-- Wrong -->
<profile name="Valideur RH">

<!-- Correct -->
<profile name="Valideur_RH">
```

## Validation Report

On success:
```
✓ Profile Validation Successful

File: docs/artifacts/profile.xml
Size: 2,456 bytes
Profiles: 6 custom profiles (NO default profiles)
Status: Valid

The Profile is ready to import into Bonita Studio.

Note: Default profiles (User, Administrator, Process manager) are in default_profile.xml
```

On failure:
```
✗ Profile Validation Failed

File: docs/artifacts/profile.xml
Size: 2,456 bytes
Status: Invalid

Errors found:
-------------------
Line 8: Element 'profile', attribute 'isDefault': Invalid value 'yes'
Expected: "true" or "false"

Solution:
Replace isDefault="yes" with isDefault="false"

Fix the errors above and re-run validation.
```

## Next Steps

After generating Profile:
1. Review the generated XML for completeness
2. Import into Bonita Studio to test
3. Use with `/bonita-generate-organization` and `/bonita-generate-bom` to create full application
4. Assign profiles to users in Bonita Portal after deployment

## Notes

- Profiles define access control for Bonita Portal and Living Applications
- Role-based mapping is most flexible and maintainable
- **CRITICAL**: Generated CNAF_profiles.xml contains ONLY custom profiles with `isDefault="false"`
- **CRITICAL**: Default profiles (User, Administrator, Process manager) are in default_profile.xml and must NOT be duplicated
- Profile names must be unique within the file
- Empty mapping elements (`<users/>`) are valid and required
- Walter Bates user should be added to an admin profile for Bonita Studio
- The skill automatically validates the generated XML
- If validation fails, the file is still created but errors are reported
- File is saved as `app/profiles/CNAF_profiles.xml` (per README_profile.md)

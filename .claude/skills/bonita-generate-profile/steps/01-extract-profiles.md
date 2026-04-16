# Step 1: Extract Profiles from Analysis Document

Extract profile definitions from the analysis document based on actors and roles.

## Input

- Analysis document path (from `--input` parameter or most recent .adoc in `docs/out/`)

## Process

1. Find most recent analysis document if not specified
2. Read the analysis document (AsciiDoc format)
3. Locate the Actors/Roles/Profiles section
4. Extract actor definitions with their roles and responsibilities
5. Map actors to organizational roles
6. Identify which profiles are needed
7. Determine if standard Bonita profiles should be included

## Finding the Analysis Document

If `--input` not provided:
```bash
# Find most recent .adoc file in docs/out/
ls -t docs/out/*.adoc | head -1
```

## Locating Actors/Roles Section

The analysis document typically contains a section titled one of:
- "Actors"
- "Acteurs"
- "Roles"
- "Rôles"
- "Profiles"
- "Profils"
- "Access Control"
- "Contrôle d'accès"

Look for AsciiDoc section markers:
```asciidoc
== Actors and Roles
== Acteurs
=== Profile Definitions
```

## Extracting Actor Information

For each actor found, extract:

### 1. Actor Name
- Usually a header (=== ActorName) or bold text
- Convert to valid profile name (alphanumeric, underscore)
- Example: "Valideur RH" → "Valideur_RH"

### 2. Actor Description
- Paragraph describing the actor's purpose and responsibilities
- Use for `<description>` element in profile XML
- Example: "Profile pour les validateurs du service RH"

### 3. Role Mapping
- Which organizational roles this actor corresponds to
- May be explicitly listed or inferred from context
- Example: "Valideur RH" → roles: "valideur_rh", "admin_rh"

### 4. Access Requirements
- What the actor needs to access
- Process permissions
- Application features
- This helps determine if the actor needs a custom profile

## Common Actor Patterns

### Process Actors

Actors directly involved in process execution:

```
=== Demandeur
Initiates recruitment requests. Creates and submits FEB forms.
Role: demandeur

=== Valideur RH
Validates recruitment requests from HR perspective.
Roles: valideur_rh, admin_rh

=== Valideur CG
Validates budget and financial aspects.
Role: valideur_cg
```

### Administrative Actors

Actors with system administration responsibilities:

```
=== Admin RH
Manages HR system configuration and user access.
Roles: admin_rh

=== System Administrator
Full system access for technical administration.
Standard Bonita Administrator profile.
```

### End User Actors

General users who may only view or use specific features:

```
=== Employee
All employees can view their own requests.
Standard Bonita User profile.
Role: member
```

## Extracting Profile Mappings

### From Tables

| Actor | Description | Roles | Profile Type |
|-------|-------------|-------|--------------|
| Demandeur | Request initiator | demandeur | Custom |
| Valideur RH | HR validator | valideur_rh, admin_rh | Custom |
| Administrator | System admin | member | Standard |

### From Lists

```
Actors:
- Demandeur: Creates recruitment requests
  - Role: demandeur
  - Custom profile required

- Valideur RH: HR validation
  - Roles: valideur_rh, admin_rh
  - Custom profile required

- All users: General access
  - Role: member
  - Standard User profile
```

### From Narrative Text

```
The recruitment process involves several actors:

1. **Demandeurs** (Request initiators): Directions and their assistants who create
   recruitment requests. They have the 'demandeur' role.

2. **Valideurs RH** (HR validators): HR department staff who validate requests.
   They have 'valideur_rh' and 'admin_rh' roles.

3. **Valideurs CG** (Budget controllers): Control de Gestion staff who validate
   budget aspects. They have the 'valideur_cg' role.
```

## CRITICAL: Excluding Default Profiles

**IMPORTANT**: Default Bonita profiles already exist in `app/profiles/default_profile.xml` and MUST NOT be extracted or generated.

### Profiles to EXCLUDE (already exist in default_profile.xml):
- **User** (isDefault="true") - Standard user profile
- **Administrator** (isDefault="true") - System administrator profile
- **Process manager** (isDefault="true") - Process management profile

### What to EXTRACT:
**ONLY custom application-specific profiles** such as:
- Initiateur
- Valideur_RH
- Valideur_Controle_Gestion
- Valideur_Budget
- Lecteur
- Administrateur_Systeme
- Any other custom actors defined in the analysis

**Rule**: If a profile has `isDefault="true"` or matches the names "User", "Administrator", or "Process manager", **DO NOT extract it**. These will be deployed separately from default_profile.xml.

## Data Structure

Store extracted information in a structured format (CUSTOM PROFILES ONLY):

```javascript
{
  "profiles": [
    {
      "name": "Demandeur",
      "description": "Profile pour les demandeurs (Directions et Assistantes de direction)",
      "isDefault": false,
      "roles": ["demandeur"],
      "users": [],
      "groups": [],
      "memberships": []
    },
    {
      "name": "Valideur_RH",
      "description": "Profile pour les validateurs du service RH",
      "isDefault": false,
      "roles": ["valideur_rh", "admin_rh"],
      "users": [],
      "groups": [],
      "memberships": []
    },
    {
      "name": "Valideur_CG",
      "description": "Profile pour les validateurs du Contrôle de Gestion",
      "isDefault": false,
      "roles": ["valideur_cg"],
      "users": [],
      "groups": [],
      "memberships": []
    }
    // NOTE: User, Administrator, Process manager profiles are NOT included
    // They already exist in default_profile.xml
  ],
  "roleReferences": ["demandeur", "valideur_rh", "admin_rh", "valideur_cg"]
}
```

**IMPORTANT**: All profiles in this structure should have `isDefault: false`. Default Bonita profiles are excluded.

## Profile Naming Rules

Convert actor names to valid profile names:

1. **Remove spaces**: "Valideur RH" → "Valideur_RH"
2. **Use alphanumeric and underscore only**: "Admin/RH" → "Admin_RH"
3. **Preserve case**: "AdminRH", "admin_rh", "Admin_RH" are all valid
4. **Avoid special characters**: Remove accents, symbols, punctuation
5. **Keep meaningful**: Names should be recognizable

Examples:
- "Demandeur" → "Demandeur" (no change needed)
- "Valideur RH" → "Valideur_RH"
- "Administrateur système" → "Administrateur_systeme"
- "Chef de projet" → "Chef_de_projet"

## Handling Missing Information

If information is incomplete:

1. **Missing actor name**: Use generic name like "Actor_1", "Custom_Profile"
2. **Missing description**: Use actor name as description
3. **Missing role mapping**: Default to "member" role
4. **No actors found**: Create profiles for standard Bonita profiles only
5. **Ambiguous roles**: Create separate profiles for each interpretation

## Role Reference Validation

Ensure extracted roles match organization definition:

1. Compare extracted role names with organization.xml roles
2. Flag any mismatches for user review
3. Suggest corrections if possible
4. Note: Validation is informational only, generation continues

Example:
```
Note: Profile 'Valideur_RH' references roles: valideur_rh, admin_rh
Ensure these roles exist in organization.xml
```

## Special Profile Types

### User-Specific Profiles

If analysis mentions specific users:
```
Walter Bates and Helen Kelly have full administrator access.
```

Extract as:
```javascript
{
  "name": "System_Admins",
  "description": "Specific system administrators",
  "isDefault": false,
  "roles": [],
  "users": ["walter.bates", "helen.kelly"],
  "groups": [],
  "memberships": []
}
```

### Group-Based Profiles

If analysis mentions organizational groups:
```
All HR department members have HR access.
```

Extract as:
```javascript
{
  "name": "HR_Department",
  "description": "All HR department members",
  "isDefault": false,
  "roles": [],
  "users": [],
  "groups": ["/Acme/HR"],
  "memberships": []
}
```

### Membership-Based Profiles

If analysis combines role and group:
```
HR managers have enhanced access.
```

Extract as:
```javascript
{
  "name": "HR_Managers",
  "description": "HR department managers",
  "isDefault": false,
  "roles": [],
  "users": [],
  "groups": [],
  "memberships": ["manager|/Acme/HR"]
}
```

## Recommended Approach

**Best Practice**: Use role-based mapping unless analysis explicitly requires other types.

**Rationale**:
- More flexible and maintainable
- Easier to manage in Bonita Portal
- Aligns with standard Bonita architecture
- Simplifies user management

## Output

Structured data containing:
- List of profiles with names and descriptions
- Profile type (custom or standard)
- Role mappings for each profile
- Optional user, group, or membership mappings
- List of all role references for validation

This data will be used in Step 2 to generate the Profile XML.

## Example Extraction

From analysis text:
```
=== Actors

The application has the following actors:

**Demandeur**: Directions and their assistants who initiate recruitment requests.
They have the 'demandeur' role in the organization.

**Valideur RH**: HR department staff who validate recruitment requests.
They have both 'valideur_rh' and 'admin_rh' roles.

**Valideur CG**: Budget control staff who validate financial aspects.
They have the 'valideur_cg' role.

All employees can view their own requests (standard User profile).
System administrators use the standard Administrator profile.
```

Extracted structure (CUSTOM PROFILES ONLY):
```javascript
{
  "profiles": [
    {
      "name": "Demandeur",
      "description": "Profile pour les demandeurs (Directions et Assistantes de direction)",
      "isDefault": false,
      "roles": ["demandeur"]
    },
    {
      "name": "Valideur_RH",
      "description": "Profile pour les validateurs du service RH",
      "isDefault": false,
      "roles": ["valideur_rh", "admin_rh"]
    },
    {
      "name": "Valideur_CG",
      "description": "Profile pour les validateurs du Contrôle de Gestion",
      "isDefault": false,
      "roles": ["valideur_cg"]
    }
    // User and Administrator profiles are NOT included - they exist in default_profile.xml
  ]
}
```

**Note**: Even though the analysis mentions "standard User profile" and "standard Administrator profile", these are NOT extracted because they already exist in default_profile.xml and will be deployed separately.

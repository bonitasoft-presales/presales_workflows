# Step 1: Extract Organization Structure from Analysis Document

Extract organization structure including users, roles, groups, and memberships from the analysis document.

## Input

- Analysis document path (from `--input` parameter or most recent .adoc in `docs/out/`)

## Process

1. Find most recent analysis document if not specified
2. Read the analysis document (AsciiDoc format)
3. Locate the organization/actors section
4. Extract roles (process actors)
5. Extract groups (organizational units and hierarchy)
6. Extract users or create representative test users
7. Map users to roles and groups (memberships)

## Finding the Analysis Document

If `--input` not provided:
```bash
# Find most recent .adoc file in docs/out/
ls -t docs/out/*.adoc | head -1
```

## Locating Organization Section

The analysis document typically contains sections titled one of:
- "Organization"
- "Organizational Structure"
- "Actors"
- "Process Actors"
- "Roles and Responsibilities"
- "Organisation"
- "Acteurs"
- "Structure organisationnelle"

Look for AsciiDoc section markers:
```asciidoc
== Organization
== Process Actors
=== Roles and Groups
=== Organizational Structure
```

## Extracting Information

### 1. Roles (Process Actors)

Roles represent the **functional actors** that perform tasks in processes.

**Common patterns:**
- DEMANDEUR - Person initiating requests
- VALIDEUR_RH - HR validator
- VALIDEUR_CG - Control and management validator
- VALIDEUR_BUDGET - Budget validator
- ADMIN_RH - HR administrator
- MANAGER - Manager role
- MEMBER - General member role

**Extraction:**
Look for:
- "Process actors:" followed by list
- "Roles:" section
- Swim lanes in process descriptions
- Task assignments mentioning actors

**Example from analysis:**
```
Process Actors:
- Demandeur: Employee initiating recruitment request
- Valideur RH: HR validator who reviews requests
- Valideur Contrôle Gestion: Control and management validator
- Valideur Budget: Budget validator
- Admin RH: HR administrator managing the process
```

**Extracted structure:**
```javascript
{
  "roles": [
    {
      "name": "demandeur",
      "displayName": "Demandeur",
      "description": "Employee initiating recruitment request"
    },
    {
      "name": "valideur_rh",
      "displayName": "Valideur RH",
      "description": "HR validator who reviews requests"
    },
    {
      "name": "valideur_cg",
      "displayName": "Valideur Contrôle Gestion",
      "description": "Control and management validator"
    },
    {
      "name": "valideur_budget",
      "displayName": "Valideur Budget",
      "description": "Budget validator"
    },
    {
      "name": "admin_rh",
      "displayName": "Admin RH",
      "description": "HR administrator managing the process"
    }
  ]
}
```

**Role naming conventions:**
- `name`: lowercase, underscore-separated (e.g., "valideur_rh")
- `displayName`: Human-readable with proper case (e.g., "Valideur RH")
- `description`: Clear explanation of the role's responsibility

### 2. Groups (Organizational Structure)

Groups represent **organizational units** with hierarchical relationships.

**Common patterns:**
- Root organization (company name)
- Departments (RH, Finance, IT, etc.)
- Sub-departments (Control Gestion, Budget under Finance)
- Regional divisions (Direction Nord, Direction Sud)

**Extraction:**
Look for:
- "Organizational structure:" section
- "Groups:" or "Departments:"
- Hierarchy diagrams
- Parent-child relationships

**Example from analysis:**
```
Organizational Structure:
- CNAF (root organization)
  - RH (Human Resources department)
  - Finance
    - Contrôle Gestion (Control and management)
    - Budget
  - Directions
    - Direction Nord
    - Direction Sud
    - Direction Est
```

**Extracted structure:**
```javascript
{
  "groups": [
    {
      "name": "cnaf",
      "parentPath": null,
      "displayName": "CNAF",
      "description": "Caisse Nationale des Allocations Familiales"
    },
    {
      "name": "rh",
      "parentPath": "/cnaf",
      "displayName": "Ressources Humaines",
      "description": "Service RH de la CNAF"
    },
    {
      "name": "finance",
      "parentPath": "/cnaf",
      "displayName": "Finance",
      "description": "Service Financier"
    },
    {
      "name": "control_gestion",
      "parentPath": "/cnaf/finance",
      "displayName": "Contrôle Gestion",
      "description": "Service de Contrôle de Gestion"
    },
    {
      "name": "budget",
      "parentPath": "/cnaf/finance",
      "displayName": "Budget",
      "description": "Service Budget"
    },
    {
      "name": "directions",
      "parentPath": "/cnaf",
      "displayName": "Directions",
      "description": "Directions métier de la CNAF"
    }
  ]
}
```

**Group naming conventions:**
- `name`: lowercase, underscore-separated (e.g., "control_gestion")
- `parentPath`: Full path to parent group (e.g., "/cnaf/finance") or null for root
- `displayName`: Human-readable (e.g., "Contrôle Gestion")
- `description`: Brief description of the group's purpose

**Building hierarchy:**
- Root groups have `parentPath: null`
- Child groups reference parent: `parentPath: "/parent"`
- Nested groups: `parentPath: "/parent/child"`

### 3. Users

Users can be explicitly listed in the analysis or created as representative test users.

**Option A: Explicit users in analysis**
```
Users:
- Marie Martin (marie.martin) - RH validator
- Jean Dupont (jean.dupont) - Control Gestion validator
- Sophie Bernard (sophie.bernard) - Budget validator
```

**Option B: Create representative test users**

If analysis doesn't specify users, create **1-2 users per role**:

**Test user patterns:**
- First name + Last name → userName (e.g., Marie Martin → marie.martin)
- Job title matches role
- Default password: "bpm" (unencrypted for testing)
- Professional email: userName@organization.com

**Example test users:**
```javascript
{
  "users": [
    {
      "userName": "marie.martin",
      "firstName": "Marie",
      "lastName": "Martin",
      "title": "Mrs",
      "jobTitle": "Responsable RH",
      "manager": null,
      "email": "marie.martin@cnaf.fr",
      "phoneNumber": "+33 1 23 45 67 89"
    },
    {
      "userName": "pierre.durand",
      "firstName": "Pierre",
      "lastName": "Durand",
      "title": "Mr",
      "jobTitle": "Responsable RH",
      "manager": null,
      "email": "pierre.durand@cnaf.fr",
      "phoneNumber": "+33 1 23 45 67 90"
    },
    {
      "userName": "jean.dupont",
      "firstName": "Jean",
      "lastName": "Dupont",
      "title": "Mr",
      "jobTitle": "Contrôleur de Gestion",
      "manager": null,
      "email": "jean.dupont@cnaf.fr",
      "phoneNumber": "+33 1 23 45 67 91"
    },
    {
      "userName": "sophie.bernard",
      "firstName": "Sophie",
      "lastName": "Bernard",
      "title": "Mrs",
      "jobTitle": "Responsable Budget",
      "manager": null,
      "email": "sophie.bernard@cnaf.fr",
      "phoneNumber": "+33 1 23 45 67 92"
    },
    {
      "userName": "luc.moreau",
      "firstName": "Luc",
      "lastName": "Moreau",
      "title": "Mr",
      "jobTitle": "Directeur",
      "manager": null,
      "email": "luc.moreau@cnaf.fr",
      "phoneNumber": "+33 1 23 45 67 93"
    }
  ]
}
```

**User naming conventions:**
- `userName`: lowercase.dot.separated (e.g., "marie.martin")
- `title`: "Mr", "Mrs", "Ms", or "Miss"
- `manager`: userName of manager (optional)
- `email`: userName@organization.domain
- `phoneNumber`: Valid format (e.g., "+33 1 23 45 67 89")

**Manager relationships:**
If analysis specifies hierarchical relationships:
```javascript
{
  "userName": "walter.bates",
  "manager": "helen.kelly"  // References another userName
}
```

### 4. Memberships (User-Role-Group Assignments)

Memberships link users to roles within groups.

**Extraction rules:**
- Each user must have **at least one membership**
- Match users to roles based on job titles
- Assign users to appropriate groups
- Users can have multiple memberships (multiple roles or groups)

**Example mapping:**
```
Marie Martin (RH validator) →
  - Role: valideur_rh
  - Group: rh (under /cnaf)

Jean Dupont (CG validator) →
  - Role: valideur_cg
  - Group: control_gestion (under /cnaf/finance)

Sophie Bernard (Budget validator) →
  - Role: valideur_budget
  - Group: budget (under /cnaf/finance)

Luc Moreau (Directeur) →
  - Role: member
  - Group: directions (under /cnaf)
```

**Extracted structure:**
```javascript
{
  "memberships": [
    {
      "userName": "marie.martin",
      "roleName": "valideur_rh",
      "groupName": "rh",
      "groupParentPath": "/cnaf"
    },
    {
      "userName": "pierre.durand",
      "roleName": "valideur_rh",
      "groupName": "rh",
      "groupParentPath": "/cnaf"
    },
    {
      "userName": "jean.dupont",
      "roleName": "valideur_cg",
      "groupName": "control_gestion",
      "groupParentPath": "/cnaf/finance"
    },
    {
      "userName": "sophie.bernard",
      "roleName": "valideur_budget",
      "groupName": "budget",
      "groupParentPath": "/cnaf/finance"
    },
    {
      "userName": "luc.moreau",
      "roleName": "member",
      "groupName": "directions",
      "groupParentPath": "/cnaf"
    }
  ]
}
```

**Membership rules:**
- `userName`: Must match a user in users section
- `roleName`: Must match a role in roles section
- `groupName` + `groupParentPath`: Must match a group in groups section

**Multiple memberships per user:**
A user can have multiple roles or belong to multiple groups:
```javascript
[
  {
    "userName": "marie.martin",
    "roleName": "valideur_rh",
    "groupName": "rh",
    "groupParentPath": "/cnaf"
  },
  {
    "userName": "marie.martin",
    "roleName": "admin_rh",
    "groupName": "rh",
    "groupParentPath": "/cnaf"
  }
]
```

## Determining Organization Name

Extract or construct organization name:
1. Look for explicit organization name in analysis
2. Use company/project name from document header
3. Default to domain-appropriate name (e.g., "acme", "company")

Examples:
- CNAF → "cnaf"
- Acme Corporation → "acme"
- Example Company → "company"

## Handling Missing Information

If information is incomplete:

1. **No roles specified**: Create standard roles:
   - member (general member)
   - manager (manager)
   - admin (administrator)

2. **No groups specified**: Create simple flat structure:
   - Root group (organization name)
   - One group per role type

3. **No users specified**: Create 1-2 test users per role with pattern:
   - firstName.lastName format
   - Job title matching role
   - Email: userName@domain

4. **No hierarchy**: Create flat group structure under root

## Common Patterns to Recognize

### Standard Roles
```
- member - General member role
- manager - Manager role
- admin - Administrator role
```

### HR Domain Roles
```
- demandeur - Requester
- valideur_rh - HR validator
- admin_rh - HR administrator
- responsable_rh - HR manager
```

### Financial Domain Roles
```
- valideur_budget - Budget validator
- valideur_cg - Control and management validator
- responsable_financier - Financial manager
```

### Hierarchical Groups
```
Root → Departments → Sub-departments → Teams
/company → /company/hr → /company/hr/recruitment → /company/hr/recruitment/team_a
```

## Data Structure Output

Store extracted information in structured format:

```javascript
{
  "organization": {
    "name": "cnaf",
    "displayName": "CNAF",
    "description": "Caisse Nationale des Allocations Familiales"
  },
  "roles": [
    // Role objects
  ],
  "groups": [
    // Group objects with hierarchy
  ],
  "users": [
    // User objects with details
  ],
  "memberships": [
    // Membership assignments
  ]
}
```

## Validation Before Step 2

Before proceeding to XML generation:
- All role names are unique
- All group name+parentPath combinations are unique
- All userNames are unique
- All memberships reference existing users, roles, and groups
- At least one user exists
- At least one role exists
- At least one group exists
- Each user has at least one membership

## Output

Structured data containing:
- Organization metadata (name, display name)
- List of roles with display names and descriptions
- List of groups with hierarchy (parentPath)
- List of users with professional data
- List of memberships linking users to roles and groups

This data will be used in Step 2 to generate the Organization XML.

## Example Complete Extraction

From analysis containing:
```
== Organization

Process managed by CNAF (Caisse Nationale des Allocations Familiales).

Actors:
- Demandeur: Employee initiating recruitment requests
- Valideur RH: HR department validates requests
- Valideur Contrôle Gestion: CG validates budget aspects
- Valideur Budget: Budget department approves funding

Structure:
- RH department handles HR validations
- Finance department (includes CG and Budget teams)
- Multiple operational directions
```

Extracted structure:
```javascript
{
  "organization": {
    "name": "cnaf",
    "displayName": "CNAF",
    "description": "Caisse Nationale des Allocations Familiales"
  },
  "roles": [
    {"name": "demandeur", "displayName": "Demandeur", "description": "Employee initiating recruitment requests"},
    {"name": "valideur_rh", "displayName": "Valideur RH", "description": "HR department validates requests"},
    {"name": "valideur_cg", "displayName": "Valideur Contrôle Gestion", "description": "CG validates budget aspects"},
    {"name": "valideur_budget", "displayName": "Valideur Budget", "description": "Budget department approves funding"},
    {"name": "member", "displayName": "Member", "description": "General member role"}
  ],
  "groups": [
    {"name": "cnaf", "parentPath": null, "displayName": "CNAF", "description": "Root organization"},
    {"name": "rh", "parentPath": "/cnaf", "displayName": "Ressources Humaines", "description": "HR department"},
    {"name": "finance", "parentPath": "/cnaf", "displayName": "Finance", "description": "Finance department"},
    {"name": "control_gestion", "parentPath": "/cnaf/finance", "displayName": "Contrôle Gestion", "description": "Control and management team"},
    {"name": "budget", "parentPath": "/cnaf/finance", "displayName": "Budget", "description": "Budget team"},
    {"name": "directions", "parentPath": "/cnaf", "displayName": "Directions", "description": "Operational directions"}
  ],
  "users": [
    {"userName": "marie.martin", "firstName": "Marie", "lastName": "Martin", "title": "Mrs", "jobTitle": "Responsable RH", "email": "marie.martin@cnaf.fr", "phoneNumber": "+33 1 23 45 67 89"},
    {"userName": "pierre.durand", "firstName": "Pierre", "lastName": "Durand", "title": "Mr", "jobTitle": "Responsable RH", "email": "pierre.durand@cnaf.fr", "phoneNumber": "+33 1 23 45 67 90"},
    {"userName": "jean.dupont", "firstName": "Jean", "lastName": "Dupont", "title": "Mr", "jobTitle": "Contrôleur de Gestion", "email": "jean.dupont@cnaf.fr", "phoneNumber": "+33 1 23 45 67 91"},
    {"userName": "sophie.bernard", "firstName": "Sophie", "lastName": "Bernard", "title": "Mrs", "jobTitle": "Responsable Budget", "email": "sophie.bernard@cnaf.fr", "phoneNumber": "+33 1 23 45 67 92"},
    {"userName": "luc.moreau", "firstName": "Luc", "lastName": "Moreau", "title": "Mr", "jobTitle": "Directeur", "email": "luc.moreau@cnaf.fr", "phoneNumber": "+33 1 23 45 67 93"}
  ],
  "memberships": [
    {"userName": "marie.martin", "roleName": "valideur_rh", "groupName": "rh", "groupParentPath": "/cnaf"},
    {"userName": "pierre.durand", "roleName": "valideur_rh", "groupName": "rh", "groupParentPath": "/cnaf"},
    {"userName": "jean.dupont", "roleName": "valideur_cg", "groupName": "control_gestion", "groupParentPath": "/cnaf/finance"},
    {"userName": "sophie.bernard", "roleName": "valideur_budget", "groupName": "budget", "groupParentPath": "/cnaf/finance"},
    {"userName": "luc.moreau", "roleName": "member", "groupName": "directions", "groupParentPath": "/cnaf"}
  ]
}
```

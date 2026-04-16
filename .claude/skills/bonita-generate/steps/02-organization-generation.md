# Step 2: Generate Organization

**Orchestration Step**: Call the `/bonita-generate-organization` sub-skill to generate the Bonita Organization XML.

## Process

This step delegates organization generation to the specialized sub-skill:

```bash
/bonita-generate-organization --input <ANALYSIS_DOC_PATH> --output docs/artifacts/organization.xml
```

Where `<ANALYSIS_DOC_PATH>` is the analysis document path determined in Step 0.

## What the Sub-Skill Does

The `/bonita-generate-organization` skill performs:

1. **Extract organization structure** from analysis document
   - Users: username, firstName, lastName, title, email
   - Roles: name, displayName, description
   - Groups: hierarchical structure with parentPath
   - Memberships: user-role-group assignments
   - Custom user info definitions

2. **Generate Bonita Organization XML**
   - Uses Organization XML schema 1.1
   - Creates test users with password "bpm"
   - Sets up hierarchical groups
   - Maps users to roles and groups via memberships
   - Includes manager relationships

3. **Validate against XSD schema**
   - Validates using `.claude/xsd/organization.xsd`
   - Reports validation errors if any
   - Ensures Bonita Studio compatibility

## Expected Output

- **File**: `docs/artifacts/organization.xml`
- **Format**: Bonita Organization XML 1.1
- **Validation**: Automatically validated against organization.xsd

## Error Handling

If the sub-skill fails:
- Display the error message from the sub-skill
- Log the failure for final summary
- Continue with next step (best effort)

Common errors:
- Analysis document missing organization section → Sub-skill will report missing data
- Invalid group hierarchy → Sub-skill validation will catch and report
- Duplicate usernames → Sub-skill will handle or report

## Verification

After sub-skill completes, verify:
- File `docs/artifacts/organization.xml` exists
- File size > 0 bytes
- Sub-skill reported success

## Continue

Proceed to Step 3 (Process generation) regardless of success/failure. All errors will be reported in final summary.

## Alternative: Manual Generation

If sub-skill is not available, fall back to manual generation following:
`.claude/skills/bonita-analyze-docs/steps/07-organization-generation.md`

But this should not be necessary as sub-skills are part of the standard skill set.

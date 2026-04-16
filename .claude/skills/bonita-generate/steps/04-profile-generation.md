# Step 4: Generate Profile

**Orchestration Step**: Call the `/bonita-generate-profile` sub-skill to generate the Bonita Profile XML.

## Process

This step delegates profile generation to the specialized sub-skill:

```bash
/bonita-generate-profile --input <ANALYSIS_DOC_PATH> --output docs/artifacts/profile.xml
```

Where `<ANALYSIS_DOC_PATH>` is the analysis document path determined in Step 0.

## What the Sub-Skill Does

The `/bonita-generate-profile` skill performs:

1. **Extract profiles** from analysis document
   - Profile names and descriptions
   - Actor/role mappings for each profile
   - Group mappings if specified
   - Access requirements by profile
   - Default profile settings

2. **Generate Bonita Profile XML**
   - Uses Profile XML schema 1.0
   - Creates profile elements with proper attributes
   - Sets isDefault="false" for custom profiles
   - Sets isDefault="true" for standard Bonita profiles
   - Maps profiles to organization roles/groups
   - Includes "User" profile as default

3. **Validate against XSD schema**
   - Validates using `.claude/xsd/profiles.xsd`
   - Reports validation errors if any
   - Ensures Bonita Studio compatibility

## Expected Output

- **File**: `docs/artifacts/profile.xml`
- **Format**: Bonita Profile XML 1.0
- **Validation**: Automatically validated against profiles.xsd

## Error Handling

If the sub-skill fails:
- Display the error message from the sub-skill
- Log the failure for final summary
- Continue with next step (best effort)

Common errors:
- Analysis document missing profiles section → Sub-skill will report missing data
- Invalid role/group mappings → Sub-skill validation will catch
- Duplicate profile names → Sub-skill will handle or report

## Verification

After sub-skill completes, verify:
- File `docs/artifacts/profile.xml` exists
- File size > 0 bytes
- Sub-skill reported success

## Continue

Proceed to Step 5 (README generation) regardless of success/failure. All errors will be reported in final summary.

## Alternative: Manual Generation

If sub-skill is not available, fall back to manual generation following:
`.claude/skills/bonita-analyze-docs/steps/11-profile-generation.md`

But this should not be necessary as sub-skills are part of the standard skill set.

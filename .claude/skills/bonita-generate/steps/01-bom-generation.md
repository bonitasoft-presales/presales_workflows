# Step 1: Generate BOM XML

**Orchestration Step**: Call the `/bonita-generate-bom` sub-skill to generate the Business Data Model.

## Process

This step delegates BOM generation to the specialized sub-skill:

```bash
/bonita-generate-bom --input <ANALYSIS_DOC_PATH> --output docs/artifacts/bom.xml
```

Where `<ANALYSIS_DOC_PATH>` is the analysis document path determined in Step 0.

## What the Sub-Skill Does

The `/bonita-generate-bom` skill performs:

1. **Extract BDM entities** from analysis document
   - Entity names, descriptions, fields
   - Field types, constraints, relationships
   - Unique constraints

2. **Generate Bonita 10.x compatible BOM XML**
   - Uses LONG foreign keys (no AGGREGATION/COMPOSITION)
   - Avoids duplicate query names
   - Adds indexes for performance
   - Proper namespace and structure

3. **Validate against XSD schema**
   - Validates using `.claude/xsd/bom.xsd`
   - Reports validation errors if any
   - Ensures Bonita Studio compatibility

## Expected Output

- **File**: `docs/artifacts/bom.xml`
- **Format**: Bonita 10.x BDM XML
- **Validation**: Automatically validated against bom.xsd

## Error Handling

If the sub-skill fails:
- Display the error message from the sub-skill
- Log the failure for final summary
- Continue with next step (best effort)

Common errors:
- Analysis document missing BDM section → Sub-skill will report missing data
- Invalid field types → Sub-skill validation will catch and report
- Duplicate entity names → Sub-skill will handle or report

## Verification

After sub-skill completes, verify:
- File `docs/artifacts/bom.xml` exists
- File size > 0 bytes
- Sub-skill reported success

## Continue

Proceed to Step 2 (Organization generation) regardless of success/failure. All errors will be reported in final summary.

## Alternative: Manual Generation

If sub-skill is not available, fall back to manual generation following:
`.claude/skills/bonita-analyze-docs/steps/06-bom-generation.md`

But this should not be necessary as sub-skills are part of the standard skill set.

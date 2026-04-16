# Step 6: Validate Artifacts

**Orchestration Step**: Call the `/bonita-validate-artifacts` sub-skill to validate all generated Bonita artifacts.

## Process

This step delegates validation to the specialized sub-skill:

```bash
/bonita-validate-artifacts --directory docs/artifacts/
```

The sub-skill will discover and validate all Bonita artifacts in the specified directory.

## What the Sub-Skill Does

The `/bonita-validate-artifacts` skill performs:

1. **Discover artifacts** in the directory
   - BOM XML files (bom.xml)
   - Organization XML files (organization.xml)
   - Process Diagram files (*.proc)
   - Profile XML files (profile.xml)

2. **Validate each artifact against XSD schema**
   - BOM: validates against `.claude/xsd/bom.xsd`
   - Organization: validates against `.claude/xsd/organization.xsd`
   - Process: validates against `.claude/xsd/ProcessDefinition.xsd`
   - Profile: validates against `.claude/xsd/profiles.xsd`
   - Reports detailed validation errors if any

3. **Check file integrity**
   - Verifies files exist and are readable
   - Checks file sizes are reasonable
   - Validates XML is well-formed
   - Reports file-specific issues

4. **Generate validation report**
   - Creates summary table of all artifacts
   - Shows status (Valid/Invalid) for each file
   - Lists file sizes
   - Details any validation errors found

## Expected Output

A validation summary table:

| File | Status | Size | Issues |
|------|--------|------|--------|
| bom.xml | ✅ Valid | XX KB | None |
| organization.xml | ✅ Valid | XX KB | None |
| ProcessName-1.0.proc | ✅ Valid | XX KB | None |
| profile.xml | ✅ Valid | XX KB | None |

## Error Handling

If validation fails:
- Display detailed error messages from sub-skill
- Identify which file(s) have issues
- Log failures for final summary
- Continue to Step 7 to report all results

Common validation errors:
- Missing required elements → Sub-skill reports XSD violations
- Invalid element values or types → Sub-skill reports details
- Malformed XML → Sub-skill reports parsing errors
- Missing files → Sub-skill reports file not found

## Verification

After sub-skill completes:
- Review validation report
- Check that all expected files were validated
- Note any validation errors for final summary
- Sub-skill reported completion status

## Continue

Proceed to Step 7 (Final summary) to report all generation and validation results.

## Alternative: Manual Validation

If sub-skill is not available, fall back to manual validation using docker commands for well-formedness checks. However, XSD schema validation will not be performed.

But this should not be necessary as sub-skills are part of the standard skill set.

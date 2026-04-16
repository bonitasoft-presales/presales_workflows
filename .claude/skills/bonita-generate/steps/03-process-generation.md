# Step 3: Generate Process Diagram

**Orchestration Step**: Call the `/bonita-generate-process` sub-skill to generate the Bonita Process Diagram.

## Process

This step delegates process diagram generation to the specialized sub-skill:

```bash
/bonita-generate-process --input <ANALYSIS_DOC_PATH> --output docs/artifacts/
```

Where `<ANALYSIS_DOC_PATH>` is the analysis document path determined in Step 0.

Note: The output directory is specified because the process filename is derived from the process name (e.g., `ProcessName-1.0.proc`).

## What the Sub-Skill Does

The `/bonita-generate-process` skill performs:

1. **Extract process structure** from analysis document
   - Process name, version, description
   - Tasks (user tasks, service tasks, script tasks)
   - Gateways (XOR for decisions, parallel if needed)
   - Actors/lanes and mappings
   - Sequence flows with conditions
   - Events (start, end)

2. **Generate Bonita Process Diagram XML**
   - Uses bonitaModelVersion="9"
   - Generates UUIDs for all elements
   - Creates proper XMI structure with namespaces
   - Sets up pools, lanes, tasks, gateways
   - Defines sequence flows with conditions
   - Maps actors to organization roles/groups
   - Includes visual notation with coordinates

3. **Validate against XSD schema**
   - Validates using `.claude/xsd/ProcessDefinition.xsd`
   - Reports validation errors if any
   - Ensures Bonita Studio compatibility

## Expected Output

- **File**: `docs/artifacts/<ProcessName>-1.0.proc`
- **Format**: Bonita BPMN 2.0 Process Diagram
- **Validation**: Automatically validated against ProcessDefinition.xsd

## Error Handling

If the sub-skill fails:
- Display the error message from the sub-skill
- Log the failure for final summary
- Continue with next step (best effort)

Common errors:
- Analysis document missing process workflow → Sub-skill will report missing data
- Invalid task types or gateway configurations → Sub-skill validation will catch
- Actor/role mapping issues → Sub-skill will report

## Verification

After sub-skill completes, verify:
- File `docs/artifacts/<ProcessName>-1.0.proc` exists
- File size > 0 bytes
- Sub-skill reported success

## Continue

Proceed to Step 4 (Profile generation) regardless of success/failure. All errors will be reported in final summary.

## Alternative: Manual Generation

If sub-skill is not available, fall back to manual generation following:
`.claude/skills/bonita-analyze-docs/steps/10-process-diagram-generation.md`

But this should not be necessary as sub-skills are part of the standard skill set.

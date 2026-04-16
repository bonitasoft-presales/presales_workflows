# Step 0: Cleanup Previously Generated Analysis

**Purpose:** Ask the user if they want to clean up previously generated analysis documents from `docs/out/` before starting a new analysis.

## Rationale

When re-running the analysis skill, old analysis documents may cause confusion. This step ensures a clean slate.

**Note:** This skill only generates .adoc analysis files. For XML and .proc artifact generation, use the `/bonita-generate` skill separately.

## Execution

### 1. Check for existing artifacts

Check if the `docs/out/` directory exists and contains any artifacts:

```bash
if [ -d "docs/out" ]; then
  echo "Checking for existing artifacts in docs/out/..."
  ls -lh docs/out/ 2>/dev/null || echo "docs/out/ is empty"
else
  echo "docs/out/ directory does not exist yet"
fi
```

### 2. Ask user if cleanup should be performed

**Use AskUserQuestion tool** to ask the user:

```json
{
  "questions": [
    {
      "question": "Do you want to clean up previously generated artifacts from docs/out/ before starting?",
      "header": "Cleanup",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes, clean up old analysis",
          "description": "Remove all *.adoc files from docs/out/ to ensure a fresh start"
        },
        {
          "label": "No, keep existing files",
          "description": "Keep existing files. New analysis will have a timestamped filename."
        }
      ]
    }
  ]
}
```

### 3. Perform cleanup if requested

If user selects "Yes, clean up old analysis":

```bash
echo "🧹 Cleaning up docs/out/..."

# Create docs/out if it doesn't exist
mkdir -p docs/out

# List files to be removed
echo "Analysis files to be removed:"
ls -lh docs/out/*.adoc 2>/dev/null || echo "  (none)"

# Remove analysis documents
rm -f docs/out/*.adoc

echo "✅ Cleanup complete"
```

If user selects "No, keep existing files":

```bash
echo "ℹ️  Keeping existing files. New analysis will have a timestamped filename."
```

## Important Notes

- This step only removes analysis documents (*.adoc)
- It does NOT remove the `docs/in/` input documents
- It does NOT remove artifact files (*.xml, *.proc) - those are managed by `/bonita-generate`
- It does NOT remove any files outside the `docs/out/` directory
- This step is OPTIONAL - the skill will work fine if user chooses not to clean up

## Expected Outcome

- User has been asked about cleanup preference
- If cleanup was requested, `docs/out/` is clean and ready for new artifacts
- If cleanup was declined, existing artifacts remain
- Proceed to Step 1: Document Analysis

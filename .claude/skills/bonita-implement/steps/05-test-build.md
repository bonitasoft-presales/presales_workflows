# Step 5: Test Build

## Objective

Verify that the Bonita project builds successfully with the newly deployed artifacts.

## Pre-checks

1. Verify Maven wrapper exists: `./mvnw`
2. Confirm all previous steps completed successfully

## Build Test Process

**Run Maven clean package:**

```bash
echo "🔨 Running build test: ./mvnw clean package"
echo "This may take a few minutes..."
echo ""

# Capture both stdout and stderr
./mvnw clean package > build-output.log 2>&1
BUILD_EXIT_CODE=$?
```

## Check Build Result

**If build succeeds (exit code 0):**

```bash
if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo "✅ Build PASSED - All artifacts integrated successfully!"
  echo ""
  echo "Build artifacts created:"
  ls -lh app/target/*.zip app/target/*.bconf 2>/dev/null | tail -5
  echo ""
  echo "Deployment Summary:"
  echo "  - BDM: bdm/bom.xml"
  echo "  - Organization: app/organizations/organization.xml"
  echo "  - Profiles: app/profiles/profile.xml"
  echo "  - Diagrams: app/diagrams/*.proc"
  echo ""
  echo "Backups preserved in: $(cat .bonita-implement-backup-path.txt)"
  echo ""
  echo "Next steps:"
  echo "  1. Open Bonita Studio"
  echo "  2. Import the process diagrams from app/diagrams/"
  echo "  3. Import the BDM from bdm/bom.xml"
  echo "  4. Import and publish the organization"
  echo "  5. Review and test the application"

  # Clean up temp file
  rm -f .bonita-implement-backup-path.txt

  exit 0
fi
```

**If build fails (exit code != 0):**

```bash
if [ $BUILD_EXIT_CODE -ne 0 ]; then
  echo "❌ Build FAILED"
  echo ""
  echo "The build failed after deploying the artifacts."
  echo ""

  # Show error preview
  echo "Error preview (last 20 lines):"
  tail -20 build-output.log
  echo ""

  # Ask user if rollback should be performed
  # Use AskUserQuestion tool to confirm rollback
  # If user confirms: proceed to Step 6 (Rollback)
  # If user declines: preserve deployed state, exit with error

  exit $BUILD_EXIT_CODE
fi
```

## Build Output Analysis

When displaying build results, show:
- Last 50 lines of build output
- Specific error messages (look for `[ERROR]` lines)
- Failed compilation units
- Failed tests

Extract key information:

```bash
# Show errors only
echo "Build Errors:"
grep -i "\[ERROR\]" build-output.log | tail -20

# Show build summary
echo ""
echo "Build Summary:"
tail -30 build-output.log
```

## Validation Checks

Before declaring success, verify:

1. **Target directory exists:** `app/target/`
2. **ZIP artifact created:** `app/target/*.zip`
3. **BCONF file created:** `app/target/*.bconf`
4. **No compilation errors**
5. **No test failures**

## Performance Metrics

Report build performance:
- Build duration (if available in Maven output)
- Number of modules built
- Total size of built artifacts

## Error Handling

If build fails:
- **DO NOT** delete build-output.log
- Preserve error log for Step 6 (Rollback)
- Exit with non-zero status to trigger rollback

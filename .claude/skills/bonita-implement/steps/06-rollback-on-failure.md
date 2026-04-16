# Step 6: Rollback on Failure

## Objective

Restore all files from backup when build fails, ensuring the project returns to its previous working state.

## When This Step Runs

This step only executes if:
- Step 5 (Test Build) fails with non-zero exit code AND user confirms rollback
- Any earlier step encounters a fatal error (automatic rollback)

## Rollback Process

**Read backup directory path:**

```bash
BACKUP_DIR=$(cat .bonita-implement-backup-path.txt)

if [ ! -d "$BACKUP_DIR" ]; then
  echo "❌ ERROR: Backup directory not found: $BACKUP_DIR"
  exit 1
fi

echo "🔄 Rolling back changes from backup: $BACKUP_DIR"
echo ""
```

## Restore Files

**Restore BDM:**

```bash
if [ -f "${BACKUP_DIR}/bdm/bom.xml" ]; then
  cp -p "${BACKUP_DIR}/bdm/bom.xml" "bdm/bom.xml"
  echo "✅ Restored bdm/bom.xml"
else
  # Remove newly added file if no backup existed
  if [ -f "bdm/bom.xml" ]; then
    rm "bdm/bom.xml"
    echo "✅ Removed newly added bdm/bom.xml (no previous file existed)"
  fi
fi
```

**Restore Organization:**

```bash
# Remove newly added organization file
rm -f app/organizations/organization.xml

# Restore backed up files
if ls "${BACKUP_DIR}/organizations/"*.xml 1> /dev/null 2>&1; then
  cp -p "${BACKUP_DIR}/organizations/"*.xml "app/organizations/"
  echo "✅ Restored organization files"
else
  echo "ℹ️  No organization files to restore"
fi
```

**Restore Profiles:**

```bash
# Remove newly added profile file
rm -f app/profiles/profile.xml

# Restore backed up files
if ls "${BACKUP_DIR}/profiles/"*.xml 1> /dev/null 2>&1; then
  cp -p "${BACKUP_DIR}/profiles/"*.xml "app/profiles/"
  echo "✅ Restored profile files"
else
  echo "ℹ️  No profile files to restore"
fi
```

**Restore Diagrams:**

```bash
# Get list of newly copied diagrams from docs/out
NEW_DIAGRAMS=$(ls -1 docs/out/*.proc 2>/dev/null | xargs -n 1 basename)

# Remove newly added diagrams
for diagram in $NEW_DIAGRAMS; do
  if [ -f "app/diagrams/$diagram" ]; then
    rm "app/diagrams/$diagram"
    echo "  - Removed app/diagrams/$diagram"
  fi
done

# Restore backed up diagrams
if ls "${BACKUP_DIR}/diagrams/"*.proc 1> /dev/null 2>&1; then
  cp -p "${BACKUP_DIR}/diagrams/"*.proc "app/diagrams/"
  echo "✅ Restored process diagrams"
else
  echo "ℹ️  No process diagrams to restore"
fi
```

## Verify Rollback

**Confirm files restored:**

```bash
echo ""
echo "Rollback verification:"
echo "  - BDM: $(ls -lh bdm/bom.xml 2>/dev/null || echo 'not present')"
echo "  - Organizations: $(ls -1 app/organizations/*.xml 2>/dev/null | wc -l) file(s)"
echo "  - Profiles: $(ls -1 app/profiles/*.xml 2>/dev/null | wc -l) file(s)"
echo "  - Diagrams: $(ls -1 app/diagrams/*.proc 2>/dev/null | wc -l) file(s)"
```

## Display Build Error Log

**Show why the build failed:**

```bash
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "BUILD ERROR LOG"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ -f "build-output.log" ]; then
  # Show errors
  echo "Error Messages:"
  grep -i "\[ERROR\]" build-output.log | tail -30

  echo ""
  echo "───────────────────────────────────────────────────────────"
  echo "Last 50 lines of build output:"
  echo "───────────────────────────────────────────────────────────"
  tail -50 build-output.log

  echo ""
  echo "Full build log saved in: build-output.log"
else
  echo "No build log found"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
```

## Provide Guidance

**Help user understand what went wrong:**

```bash
echo ""
echo "🔍 Troubleshooting Guidance:"
echo ""
echo "Common causes of build failures:"
echo ""
echo "1. BDM Schema Issues:"
echo "   - Invalid field types or names"
echo "   - Circular dependencies in aggregations"
echo "   - Invalid JPQL queries"
echo "   - Check: bdm/bom.xml for XML schema compliance"
echo ""
echo "2. Organization Issues:"
echo "   - Invalid user/role/group definitions"
echo "   - Circular group hierarchies"
echo "   - Check: app/organizations/organization.xml"
echo ""
echo "3. Profile Issues:"
echo "   - Invalid profile mappings"
echo "   - References to non-existent roles"
echo "   - Check: app/profiles/profile.xml"
echo ""
echo "4. Process Diagram Issues:"
echo "   - Invalid XMI structure"
echo "   - Missing required elements"
echo "   - Corrupted XML"
echo "   - Check: app/diagrams/*.proc files"
echo ""
echo "Recommended actions:"
echo "  1. Review the error log above"
echo "  2. Check the specific file mentioned in errors"
echo "  3. Validate XML files with xmllint"
echo "  4. Verify generated files in docs/out/ are valid"
echo "  5. Fix issues in docs/out/ and re-run bonita-implement"
echo ""
echo "Backups are preserved in: $BACKUP_DIR"
echo "You can manually inspect backed-up files if needed"
echo ""
```

## Cleanup

**Preserve important files:**

```bash
# Keep backup directory (don't delete)
echo "Backup directory preserved: $BACKUP_DIR"

# Keep build log for investigation
echo "Build log preserved: build-output.log"

# Remove temporary tracking file
rm -f .bonita-implement-backup-path.txt
```

## Exit Status

Exit with error to indicate rollback occurred:

```bash
echo ""
echo "❌ Deployment failed and rolled back successfully"
echo "   Project is back to its previous state"
echo ""
exit 1
```

## Important Notes

- **Backups are NOT deleted** - they remain for manual inspection
- **Build log is preserved** - for detailed error analysis
- **All changes are reverted** - project should build as before
- **User can retry** - after fixing issues in docs/out/

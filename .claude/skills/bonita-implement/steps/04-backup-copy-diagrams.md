# Step 4: Backup and Copy Process Diagrams

## Objective

Safely deploy all generated process diagram files from `docs/out/*.proc` to `app/diagrams/` with backup.

## Pre-checks

1. Verify source files exist: `docs/out/*.proc`
2. Count number of `.proc` files to copy
3. Check if target directory exists: `app/diagrams/`
4. List existing `.proc` files in `app/diagrams/`

## Backup Process

**Read backup directory path from Step 1:**

```bash
BACKUP_DIR=$(cat .bonita-implement-backup-path.txt)
mkdir -p "${BACKUP_DIR}/diagrams"
```

**Backup all existing .proc files:**

```bash
if ls app/diagrams/*.proc 1> /dev/null 2>&1; then
  cp -p app/diagrams/*.proc "${BACKUP_DIR}/diagrams/"
  BACKUP_COUNT=$(ls -1 "${BACKUP_DIR}/diagrams/"*.proc 2>/dev/null | wc -l)
  echo "✅ Backed up ${BACKUP_COUNT} existing process diagram(s)"
else
  echo "ℹ️  No existing process diagrams to backup"
fi
```

## Copy Process

**Count source files:**

```bash
SOURCE_COUNT=$(ls -1 docs/out/*.proc 2>/dev/null | wc -l)
if [ "$SOURCE_COUNT" -eq 0 ]; then
  echo "❌ No .proc files found in docs/out/"
  exit 1
fi
echo "ℹ️  Found ${SOURCE_COUNT} process diagram(s) to copy"
```

**Copy all .proc files:**

```bash
cp docs/out/*.proc app/diagrams/
```

**Verify copy succeeded:**

```bash
TARGET_COUNT=$(ls -1 app/diagrams/*.proc 2>/dev/null | wc -l)
if [ "$TARGET_COUNT" -ge "$SOURCE_COUNT" ]; then
  echo "✅ Successfully copied ${SOURCE_COUNT} process diagram(s) to app/diagrams/"
else
  echo "❌ Failed to copy all process diagrams (expected: ${SOURCE_COUNT}, found: ${TARGET_COUNT})"
  exit 1
fi
```

## List Copied Files

Display the names of copied process diagrams:

```bash
echo ""
echo "Process diagrams deployed:"
ls -1 app/diagrams/*.proc | xargs -n 1 basename
```

## Validation

- Verify file sizes match for each copied file
- Check that file names are valid (no special characters that could cause issues)

## Output

Report to user:
- Number of process diagrams deployed
- List of diagram file names
- Total size of diagrams

## Error Handling

If any error occurs:
- Stop execution immediately
- Report which operation failed
- Preserve backup directory
- Do NOT proceed to next step

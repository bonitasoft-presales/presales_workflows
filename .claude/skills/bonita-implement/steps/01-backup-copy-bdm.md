# Step 1: Backup and Copy BDM

## Objective

Safely deploy the generated Business Data Model (BDM) from `docs/out/bom.xml` to `bdm/bom.xml` with backup.

## Pre-checks

1. Verify source file exists: `docs/out/bom.xml`
2. Check if target directory exists: `bdm/`
3. Check if existing BDM file exists: `bdm/bom.xml`

## Backup Process

**Create timestamped backup directory:**

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR=".backups/bonita-implement-${TIMESTAMP}"
mkdir -p "${BACKUP_DIR}/bdm"
```

**Backup existing BDM if it exists:**

```bash
if [ -f "bdm/bom.xml" ]; then
  cp -p "bdm/bom.xml" "${BACKUP_DIR}/bdm/bom.xml"
  echo "✅ Backed up existing bdm/bom.xml"
else
  echo "ℹ️  No existing bdm/bom.xml to backup"
fi
```

## Copy Process

**Copy new BDM file:**

```bash
cp "docs/out/bom.xml" "bdm/bom.xml"
```

**Verify copy succeeded:**

```bash
if [ -f "bdm/bom.xml" ]; then
  echo "✅ Successfully copied docs/out/bom.xml to bdm/bom.xml"
else
  echo "❌ Failed to copy BDM file"
  exit 1
fi
```

## Validation

- Verify file size matches: `ls -lh docs/out/bom.xml bdm/bom.xml`
- Check XML is well-formed (optional): `xmllint --noout bdm/bom.xml`

## Store Backup Path

Save the backup directory path for potential rollback:

```bash
echo "${BACKUP_DIR}" > .bonita-implement-backup-path.txt
```

## Error Handling

If any error occurs:
- Stop execution immediately
- Report which operation failed
- Preserve backup directory
- Do NOT proceed to next step

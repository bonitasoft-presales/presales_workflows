# Step 2: Backup and Copy Organization

## Objective

Safely deploy the generated organization file from `docs/out/organization.xml` to `app/organizations/` with backup.

## Pre-checks

1. Verify source file exists: `docs/out/organization.xml`
2. Check if target directory exists: `app/organizations/`
3. List existing organization files in `app/organizations/`

## Backup Process

**Read backup directory path from Step 1:**

```bash
BACKUP_DIR=$(cat .bonita-implement-backup-path.txt)
mkdir -p "${BACKUP_DIR}/organizations"
```

**Backup all existing organization XML files:**

```bash
if ls app/organizations/*.xml 1> /dev/null 2>&1; then
  cp -p app/organizations/*.xml "${BACKUP_DIR}/organizations/"
  echo "✅ Backed up existing organization files"
else
  echo "ℹ️  No existing organization files to backup"
fi
```

## Copy Process

**Copy new organization file:**

```bash
cp "docs/out/organization.xml" "app/organizations/organization.xml"
```

**Verify copy succeeded:**

```bash
if [ -f "app/organizations/organization.xml" ]; then
  echo "✅ Successfully copied docs/out/organization.xml to app/organizations/organization.xml"
else
  echo "❌ Failed to copy organization file"
  exit 1
fi
```

## Validation

- Verify file size matches: `ls -lh docs/out/organization.xml app/organizations/organization.xml`
- Check XML is well-formed (optional): `xmllint --noout app/organizations/organization.xml`
- Verify organization schema compliance (check for required elements: users, roles, groups, memberships)

## Output

Report to user:
- Number of users defined
- Number of roles defined
- Number of groups defined
- Number of memberships defined

## Error Handling

If any error occurs:
- Stop execution immediately
- Report which operation failed
- Preserve backup directory
- Do NOT proceed to next step

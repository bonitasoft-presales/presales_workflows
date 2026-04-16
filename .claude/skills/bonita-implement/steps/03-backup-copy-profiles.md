# Step 3: Backup and Copy Profiles

## Objective

Safely deploy the generated profile file from `docs/out/profile.xml` to `app/profiles/` with backup.

## Pre-checks

1. Verify source file exists: `docs/out/profile.xml`
2. Check if target directory exists: `app/profiles/`
3. List existing profile files in `app/profiles/`

## Backup Process

**Read backup directory path from Step 1:**

```bash
BACKUP_DIR=$(cat .bonita-implement-backup-path.txt)
mkdir -p "${BACKUP_DIR}/profiles"
```

**Backup all existing profile XML files:**

```bash
if ls app/profiles/*.xml 1> /dev/null 2>&1; then
  cp -p app/profiles/*.xml "${BACKUP_DIR}/profiles/"
  echo "✅ Backed up existing profile files"
else
  echo "ℹ️  No existing profile files to backup"
fi
```

## Copy Process

**Copy new profile file:**

```bash
cp "docs/out/profile.xml" "app/profiles/profile.xml"
```

**Verify copy succeeded:**

```bash
if [ -f "app/profiles/profile.xml" ]; then
  echo "✅ Successfully copied docs/out/profile.xml to app/profiles/profile.xml"
else
  echo "❌ Failed to copy profile file"
  exit 1
fi
```

## Validation

- Verify file size matches: `ls -lh docs/out/profile.xml app/profiles/profile.xml`
- Check XML is well-formed (optional): `xmllint --noout app/profiles/profile.xml`
- Verify profile schema compliance (check for required elements: profiles, profileMapping)

## Output

Report to user:
- Number of profiles defined
- Profile names
- Default profiles (if any)

## Error Handling

If any error occurs:
- Stop execution immediately
- Report which operation failed
- Preserve backup directory
- Do NOT proceed to next step

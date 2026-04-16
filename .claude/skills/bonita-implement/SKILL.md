---
name: bonita-implement
description: Implement Bonita project by copying generated artifacts into the project structure and running a Maven build. Use when the user wants to implement, apply, integrate, or copy generated artifacts into the project.
disable-model-invocation: true
argument-hint: "[--input <artifacts-dir>]"
allowed-tools: Read, Write, Bash, Glob, Grep
---

# Bonita Implement Skill

Deploy generated Bonita artifacts from `docs/out/` into the Bonita project structure with automatic backup and rollback on failure.

## Overview

This skill safely integrates generated artifacts (BDM, organization, profiles, process diagrams) into the Bonita project structure. It creates backups before making changes and automatically reverts if the build fails.

## Global Directives

**IMPORTANT GLOBAL DIRECTIVE**:
- Use timestamps for backup directories: `backup-YYYYMMDD-HHMMSS`
- All file operations should preserve original file permissions
- Build tests should capture full output for error diagnosis
- If build fails, show error preview and ask user if rollback should be performed
- If any pre-build step fails, stop immediately and trigger automatic rollback

## Execution Steps

Follow these steps in order:

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--input`) before starting.

### Step 1: Backup and Copy BDM
[Read detailed instructions](steps/01-backup-copy-bdm.md)
- Create timestamped backup of existing `bdm/bom.xml`
- Copy `docs/out/bom.xml` to `bdm/bom.xml`
- Verify file copied successfully

### Step 2: Backup and Copy Organization
[Read detailed instructions](steps/02-backup-copy-organization.md)
- Create timestamped backup of existing organization files in `app/organizations/`
- Copy `docs/out/organization.xml` to `app/organizations/`
- Verify file copied successfully

### Step 3: Backup and Copy Profiles
[Read detailed instructions](steps/03-backup-copy-profiles.md)
- Create timestamped backup of existing profile files in `app/profiles/`
- Copy `docs/out/profile.xml` to `app/profiles/`
- Verify file copied successfully

### Step 4: Backup and Copy Process Diagrams
[Read detailed instructions](steps/04-backup-copy-diagrams.md)
- Create timestamped backup of existing `.proc` files in `app/diagrams/`
- Copy all `docs/out/*.proc` files to `app/diagrams/`
- Verify files copied successfully

### Step 5: Test Build
[Read detailed instructions](steps/05-test-build.md)
- Run `./mvnw clean package` to verify project builds
- Capture full build output
- If build succeeds, proceed to cleanup
- If build fails, show error preview and ask user if rollback should be performed

### Step 6: Rollback on Failure (Optional)
[Read detailed instructions](steps/06-rollback-on-failure.md)
- Only runs if user confirms rollback after build failure
- Restore all files from timestamped backups
- Display build error log to user
- Provide guidance on what went wrong
- Exit with error status

## Success Criteria

- All artifacts deployed to correct locations
- Build passes with `./mvnw clean package`
- Backups created and preserved (not deleted on success)
- User informed of successful deployment

## Rollback Criteria

- Build fails after artifact deployment AND user confirms rollback
- If rollback confirmed: all files reverted to pre-deployment state
- If rollback declined: deployed files remain for investigation
- Error log displayed to user
- User can investigate and retry

## Output Format

Present clear status messages for each step:
- ✅ Step completed successfully
- ⚠️  Warning or issue detected
- ❌ Step failed, triggering rollback

## Files Affected

- `bdm/bom.xml`
- `app/organizations/organization.xml` (or similar name)
- `app/profiles/profile.xml` (or similar name)
- `app/diagrams/*.proc`

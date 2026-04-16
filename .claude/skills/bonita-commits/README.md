# Bonita Commits Skill

## Purpose

Analyze and rewrite commit history in the current branch or PR to ensure commits are logically grouped and consistent with best practices.

## What It Does

This skill helps you clean up messy commit history by:

1. **Analyzing** all commits in your current branch
2. **Identifying** related changes that should be grouped together
3. **Proposing** a reorganization plan with logical commit groupings
4. **Rewriting** the commit history with your approval
5. **Ensuring** each commit is atomic, clear, and follows conventions

## When to Use

Use this skill when:

- You have many small WIP commits that should be consolidated
- Your PR has commits that should be logically grouped
- You have "fix typo" or "oops" commits after main changes
- You want to clean up history before merging
- Your commits mix unrelated changes
- You need to follow team commit conventions

## Usage

```bash
/bonita-commits
```

The skill will:
1. Show you the current commit structure
2. Analyze and propose logical groupings
3. Ask for your approval
4. Create a backup branch
5. Rewrite the history
6. Show you the results

## Safety

- **Always creates a backup branch** before making changes
- **Requires your approval** before rewriting
- **Preserves all changes** - never loses work
- **Verifies** the rewrite was successful
- Provides recovery instructions if needed

## Example

**Before:**
```
abc1234 fix typo
def5678 WIP
ghi9012 add feature X
jkl3456 forgot to add file
mno7890 update config
pqr1234 fix lint
```

**After:**
```
abc1234 feat: add feature X with configuration
def5678 chore: update linting configuration
```

## Requirements

- Git repository with commits to reorganize
- Branch must have commits not in the base branch
- You must have permission to force push (for updating remote)

## Bonita-Specific Features

- Recognizes Bonita version migration commits
- Understands Bonita project structure
- Follows presales team commit conventions
- Groups infrastructure/workflow changes appropriately

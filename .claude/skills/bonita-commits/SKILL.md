---
name: bonita-commits
description: Analyze and rewrite git commit history for logical grouping and consistency. Use when the user wants to clean up, rewrite, squash, reorganize, or improve commits in the current branch.
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
---

# Bonita Commits Skill

Analyze and rewrite commit history in the current branch or PR to ensure commits are logically grouped and consistent.

## Instructions

Follow these steps to analyze and rewrite commit history:

### 1. Identify the Base Branch and Commits

* Determine the current branch name
* Identify the base branch (usually `main`, `master`, or `develop`)
* Get the list of commits in the current branch that are not in the base branch
* For each commit, gather:
  - Commit hash (short)
  - Commit message
  - Files changed
  - Lines added/removed
  - Author and date

### 2. Analyze Commit Content

For each commit:
* Read the actual changes (use `git show <commit>` or `git diff`)
* Understand what the commit does:
  - Is it a feature addition?
  - Is it a bug fix?
  - Is it refactoring?
  - Is it documentation?
  - Is it configuration/infrastructure?
  - Is it a dependency update?
  - Is it a Bonita version migration?
* Identify related commits that should be grouped together

### 3. Identify Logical Groupings

Group commits by:
* **Feature/functionality** - Related feature work should be in one commit
* **Bug fixes** - Each distinct bug fix should be separate
* **Refactoring** - Code restructuring without behavior changes
* **Documentation** - Doc updates can be grouped
* **Infrastructure/Config** - CI/CD, build config, etc.
* **Dependencies** - Dependency updates
* **Bonita migrations** - Version migrations should be atomic

**Anti-patterns to fix:**
- "WIP" or "temp" commits
- "Fix typo" after main commit
- Multiple unrelated changes in one commit
- Feature split across many small commits
- Commits that partially revert previous commits

### 4. Propose Reorganization Plan

Present a clear plan to the user:
* Show current commit structure (with hashes and messages)
* Show proposed new commit structure:
  - Which commits will be squashed together
  - New commit messages for each logical group
  - Order of commits (most foundational first)
* Explain the reasoning for each grouping
* **Ask for user approval before proceeding**

Use AskUserQuestion to confirm the plan or get user preferences.

### 5. Execute the Rewrite

**IMPORTANT Git Rebase Safety:**
- NEVER use `git rebase -i` (interactive mode doesn't work in automation)
- NEVER use `git reset --hard` without explicit user approval
- ALWAYS warn the user that history rewriting requires force push
- Create a backup branch before starting: `git branch backup-<original-branch>-<timestamp>`

**Rewrite approaches:**

Option A - Using git reset and selective commits:
```bash
# Create backup
git branch backup-<branch>-$(date +%s)

# Reset to base branch
git reset --soft <base-branch>

# Create new logical commits by staging specific files
git reset HEAD
git add <files-for-commit-1>
git commit -m "message 1"
git add <files-for-commit-2>
git commit -m "message 2"
# etc.
```

Option B - Using git cherry-pick and squash:
```bash
# Create backup
git branch backup-<branch>-$(date +%s)

# Create temporary branch from base
git checkout -b temp-rewrite <base-branch>

# Cherry-pick and squash commits
git cherry-pick <commit1> <commit2>
git reset --soft HEAD~2
git commit -m "new grouped message"

# Replace original branch
git branch -D <original-branch>
git branch -m <original-branch>
```

### 6. Verify and Report

After rewriting:
* Show the new commit history (`git log --oneline`)
* Show a comparison of before/after
* Verify all changes are preserved (`git diff <backup-branch>`)
* Provide instructions for force pushing: `git push --force-with-lease`
* Remind about the backup branch location

### 7. Commit Message Standards

Ensure all new commit messages follow best practices:
* Use imperative mood ("Add feature" not "Added feature")
* Start with a type prefix when appropriate:
  - `feat:` - New feature
  - `fix:` - Bug fix
  - `refactor:` - Code refactoring
  - `docs:` - Documentation
  - `chore:` - Build/config/dependencies
  - `test:` - Test additions/changes
* Keep first line under 72 characters
* Add detailed description in body if needed
* Reference issue/ticket numbers if applicable
* Include Co-Authored-By for Claude commits

**Bonita-specific conventions:**
- Bonita version migrations should be clearly marked: "Bonita 'X.Y.Z' automated migration"
- Infrastructure updates: "update <component> to version X.Y.Z"
- Include relevant context about what was changed and why

## Error Handling

If errors occur during rebase/rewrite:
* Explain what went wrong
* Show how to recover using the backup branch
* Offer to abort and restore original state
* Never leave the repository in a broken state

## Tips

- Always create a backup branch before rewriting history
- Preserve all changes - never lose work
- Make sure each commit is atomic and self-contained
- Each commit should leave the codebase in a working state
- Don't be afraid to ask the user for clarification on grouping decisions
- For complex histories, consider doing the rewrite in stages

---
name: bonita-github-actions
description: Analyze and inspect GitHub Actions workflows in Bonita projects, including checking for updates to presales_workflows actions. Use when the user wants to check, analyze, update, or inspect GitHub Actions workflows.
argument-hint: "[--workflow <name>]"
allowed-tools: Bash(gh *), Read, Glob, Grep
---

Analyze GitHub Actions workflows in this repository, with specialized validation for Bonita-specific configurations and presales_workflows integration.


Follow these steps:

* Look for workflow files in `.github/workflows/` directory
* For each workflow file found:
  * Parse and understand the workflow structure
  * Identify:
    - Workflow name and triggers (on push, pull_request, schedule, etc.)
    - Jobs defined and their dependencies
    - Steps in each job
    - Actions used (with versions)
    - Environment variables and secrets referenced
    - Matrix configurations if present
    - Timeout settings and runner types
  * **Special handling for Bonita licence secrets:**
    * If an action call uses the `licence_base64` parameter, verify the repository secret uses version-specific naming
    * The secret should be named `LICENCE_V{major}_{minor}_BASE64` where the version matches the project's Bonita version
    * Example: For Bonita 10.2.x projects, use `LICENCE_V10_2_BASE64`
    * Read the project version from `pom.xml` in the `<parent><version>` field
    * Validate the workflow maps the parameter correctly: `licence_base64: ${{ secrets.LICENCE_V10_2_BASE64 }}` 
  * **IMPORTANT**: Specifically check if workflows use remote actions from `bonitasoft-presales/presales_workflows` repository
    - Identify which actions from this repo are used (e.g., `bonitasoft-presales/presales_workflows/.github/actions/...`)
    - Note the version/ref used (commit SHA, tag, or branch)
    - List which workflows use these remote actions
    - **Check if newer versions are available**:
      * Use `gh api` to check the latest commits/tags in `bonitasoft-presales/presales_workflows`
      * Compare current version/ref used in workflows with latest available
      * Report if updates are available and what changed
      * Always check parameters and secrets required
      * **Suggest to update them**: If newer versions are found, offer to update the workflow files to use the latest version
        - Show what will be changed (old ref → new ref)
        - Ask user for confirmation before making changes
        - Update the workflow files if user approves
  * Check for common issues:
    - Deprecated actions
    - Missing required secrets/variables
    - Potential security concerns
    - Inefficient configurations
* Provide a summary report showing:
  * List of all workflows with their triggers
  * Dependency graph between jobs
  * External actions used (grouped by owner/repo)
    - **Highlight actions from `bonitasoft-presales/presales_workflows` separately**
  * Environment requirements (secrets, variables)
* If asked for specific workflow:
  * Provide detailed analysis of that workflow
  * Explain what each job and step does
  * Suggest improvements if applicable
* Use `gh` CLI when possible to check:
  * Recent workflow runs and their status
  * Workflow execution history
  * Failed runs and error messages

Present findings in a clear, structured format suitable for developers.

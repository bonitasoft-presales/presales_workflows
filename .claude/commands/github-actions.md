Review or create GitHub Actions workflows in this repository following these conventions:

## Naming conventions

| Purpose          | Prefix      | Notes                                                        |
|------------------|-------------|--------------------------------------------------------------|
| Reusable action  | `reusable_` | Callable from external repositories via `workflow_call`      |
| Test action      | `test_`     | Validates the matching `reusable_` workflow, same suffix     |

## Rules to enforce

- Every `reusable_*.yml` workflow **must** have a matching `test_*.yml` workflow.
- Test workflows must be triggered only by `workflow_dispatch` with required input parameters.
- When a test workflow depends on artifacts produced by a previous job, mock the expected artifact content instead of running the full chain.
- Every job step that produces meaningful output (artifacts, env vars, results) **must** append a formatted markdown summary to `$GITHUB_STEP_SUMMARY`, including: workflow name, version, step name, and relevant values.
- Every external GitHub Action **must** use the latest major version tag. Check with `gh api repos/{owner}/{action}/releases/latest --jq '.tag_name'` and update if behind. Known latest versions (as of 2026-04-10):
  - `actions/checkout@v6`
  - `actions/upload-artifact@v7`
  - `actions/download-artifact@v8`
  - `actions/setup-java@v5`
  - `aws-actions/configure-aws-credentials@v6`
  - `dorny/test-reporter@v3`
  - `passeidireto/aws-add-ip-to-security-group-action@v1.0.0`
  - `1arp/create-a-file-action@0.4.5`
  - `pietrobolcato/action-read-yaml@1.1.0`
  - `whelk-io/maven-settings-xml-action@v22`

## Documentation

- `README.adoc` must be updated to reflect any new or changed workflow before committing.

Apply these rules to the workflow(s) currently being discussed or modified. Flag any violations and suggest fixes.

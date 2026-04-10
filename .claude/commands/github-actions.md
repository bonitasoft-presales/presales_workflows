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
- each external github action may check to use latest version

## Documentation

- `README.adoc` must be updated to reflect any new or changed workflow before committing.

Apply these rules to the workflow(s) currently being discussed or modified. Flag any violations and suggest fixes.

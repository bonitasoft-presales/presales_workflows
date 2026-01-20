# Github actions guidelines

## naming conventions

| purpose         | prefix    | comment                                                   |
|-----------------|-----------|-----------------------------------------------------------|
| reusable action | reusable_ | action callable from external repositories                |
| test action     | test_     | demo action to validate  **reusable_** , with same suffix | 

## required actions for reusable actions

Create test action for each reusable action. Test actions should be only on workflow_dispatch, with required parameters.

When actions depend on a previous action, mock expected content.

Each action should provide relevant information about artifacts, env var setting in $GITHUB_STEP_SUMMARY, with job, version and step name.

## Documentation

Always keep README up to date with latest changes **before** commit.

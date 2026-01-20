# Github actions guidelines

## naming conventions

| purpose         | prefix    | comment                                                   |
|-----------------|-----------|-----------------------------------------------------------|
| reusable action | reusable_ | action callable from external repositories                |
| test action     | test_     | demo action to validate  **reusable_** , with same suffix | 

## required actions for reusable actions

### create test action for each reusable action. 

test action should be only on workflow dispatch, with required parameters

exclusions:

| suffix        | required          | comment |
|---------------|-------------------|---------|
| build_sca     | no                |         |
| create_server | workflow dispatch |         |
| deploy_sca    | no                |         |
| deploy_uib    | no                |         |
| run_it        | no                |         |
| run_datagen   | no                |         |



### when actions depends on a previous action, just mock expected content

### each action should provide relevant information about artifacts, env var setting in $GITHUB_STEP_SUMMARY , with job, version  and step step name
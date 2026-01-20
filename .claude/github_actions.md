# Github actions guidelines

## naming conventions

| purpose         | prefix    | comment                                                   |
|-----------------|-----------|-----------------------------------------------------------|
| reusable action | reusable_ | action callable from external repositories                |
| test action     | test_     | demo action to validate  **reusable_** , with same suffix | 

## required actions for reusable actions

create test action for each reusable action
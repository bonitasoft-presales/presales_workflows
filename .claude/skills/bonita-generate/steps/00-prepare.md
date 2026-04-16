# Step 0: Prepare and Read Analysis

## Create artifacts directory

Create the `docs/artifacts/` directory if it doesn't exist:

```bash
mkdir -p docs/artifacts
```

## Find analysis documents

Look for .adoc files in `docs/out/`:

```bash
ls -lh docs/out/*.adoc
```

## Ask user which document to use

If multiple .adoc files exist, ask the user which one to use. If only one exists, use it automatically.

## Read the analysis document

Read the selected .adoc file completely. This document contains all the information needed to generate the Bonita artifacts:

- BDM entities (in the "Modèle de données" or "BOM" section)
- Users, roles, groups (in the "Organisation" section)
- Process workflow (in the "Processus métier" section)
- Profiles (in the "Profils" section)

## Extract key information

From the analysis document, identify:

1. **Project name** and **process name**
2. **BDM entities** with their fields and relationships
3. **Actors** and **roles** in the process
4. **Users** to create in the organization
5. **Groups** organizational structure
6. **Process tasks** and **workflow flow**
7. **Profiles** and their mappings

Store this information for use in subsequent steps.

## Validation

Confirm that:
- The analysis document exists and is readable
- Key sections are present (BOM, Organization, Process)
- The document is complete enough to generate artifacts

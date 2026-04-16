= instructions for BOM generation

**CRITICAL** : read and apply conventions located in `context-ia/02-datamodel` 

== example

read this example: https://raw.githubusercontent.com/bonitasoft-presales/showroom-cloud/refs/heads/master/bdm/bom.xml?token=GHSAT0AAAAAADSSUN4QF5IFRWTX2FB4FMWI2LYTYSQ for a full example


== specific to this project

**CRITICAL** always add a `length` attribute for **ALL** field types without exception:
- STRING fields: use `length="255"` as default (or smaller if specified, e.g., `length="50"` for codes)
- INTEGER fields: use `length="10"` as standard
- ALL other field types (TEXT, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME): use `length="255"` as default
- **NEVER create ANY field without a length attribute**
- This is a PROJECT REQUIREMENT for all BDM fields

**CRITICAL** never use blacklisted/reserved field names:
- **FORBIDDEN:** `description`, `persistenceId`, `persistenceVersion`, `class`, `type`
- **USE INSTEAD:** `descriptionAction`, `descriptionDocument`, `commentaire`, `libelle` (context-specific)
- See `.claude/skills/bonita-generate-bom/BDM_FIELD_NAME_BLACKLIST.md` for complete list

**CRITICAL** the BDM entities prefix will be : `RH`

**CRITICAL** the output file must exist and be `bdm/bom.xml`

**CRITICAL** all fields must have business-friendly descriptions:
- **MANDATORY:** Every field MUST have a `<description>` element
- **Plain language:** Understandable by non-technical business owners
- **No jargon:** Avoid technical terms like "FK", "boolean", "varchar"
- **Include examples:** For coded/enumerated values
- **In French:** For this project
- See `.claude/skills/bonita-generate-bom/BDM_FIELD_DESCRIPTION_RULES.md` for complete guidelines

**CRITICAL** all index names must be 20 characters or less (see BDM_INDEX_NAME_RULES.md):
- Maximum length: **20 characters**
- Use abbreviations: `validation` → `valid`, `utilisateur` → `user`, `historique` → `histo`
- Pattern: `IDX_{entity}_{field}` with total ≤ 20 chars
- Examples: `IDX_FEB_statut` (14), `IDX_valid_statut` (16), `IDX_FEB_dateEmission` (20)


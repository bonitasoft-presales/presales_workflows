---
name: bonita-generate-bom
description: Generate Bonita BDM (Business Data Model) XML from analysis document. Use when the user wants to generate, create, or build the BOM, BDM, or data model XML artifact.
argument-hint: "[--input <analysis-file>] [--output <path>]"
allowed-tools: Read, Write, Bash, Glob, Grep
---

Generate a Bonita Business Data Model (BDM) XML file from an analysis document. The generated `bom.xml` file conforms to Bonita 10.x format and is validated against the XSD schema.

**CRITICAL** : read and apply `README_bom.md` before generation

**CRITICAL** : conform to  `.claude/xsd/bom.xsd` fo generation

## Usage

```bash
# Generate BOM from default analysis document
/bonita-generate-bom

# Generate BOM from specific analysis document
/bonita-generate-bom --input docs/out/analyse-project-2026-01-23.adoc

# Generate BOM to custom output path
/bonita-generate-bom --input docs/out/analyse-project-2026-01-23.adoc --output custom/path/bom.xml
```

## Parameters

- `--input <path>` - Path to analysis document (default: most recent .adoc in `docs/out/`)
- `--output <path>` - Output path for BOM file (default: `docs/artifacts/bom.xml`)

## Prerequisites

- Analysis document containing BDM section with entity definitions
- Docker for XSD validation
- XSD schema at `.claude/xsd/bom.xsd`

## Global Directives

**IMPORTANT**: Use Docker for all tooling:
- XML validation: `docker run --rm alpine:latest sh -c "apk add --no-cache libxml2-utils >/dev/null 2&1 && xmllint ...`
- Python scripts: `docker run --rm python:3 python3 -c "..."`

## Execution Steps

Follow these steps in order:

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--input`, `--output`) before starting.

### Step 1: Extract BDM Entities
[Read detailed instructions](steps/01-extract-entities.md)
- Read analysis document (AsciiDoc format)
- Find BDM/Data Model section
- Extract entity definitions with fields, types, relationships
- Identify unique constraints
- Map field types to Bonita types

### Step 2: Generate BOM XML
[Read detailed instructions](steps/02-generate-xml.md)
- Create XML with proper namespace and structure
- Generate business objects for each entity
- Add fields with correct types and constraints
- Convert relationships to LONG foreign keys (Bonita 10.x format)
- Generate queries (avoid duplicates with auto-generated)
- Add indexes for performance
- Save to output path

### Step 3: Validate Against XSD
[Read detailed instructions](steps/03-validate-xsd.md)
- Validate generated XML against `bom.xsd`
- Report validation results
- Display errors if validation fails

## Output

The skill generates **1 file**:

**`bdm/bom.xml`** - Bonita BDM XML containing:
- Business object definitions
- Field definitions with types and constraints
- Unique constraints
- Custom queries for data access
- Indexes for performance

## Critical Requirements for Bonita 10.x

### 1. LENGTH ATTRIBUTE MANDATORY FOR ALL FIELDS

**CRITICAL** - **ALWAYS** add the `length` attribute for **ALL** field types without exception:

**ALL field types MUST have `length` attribute:**
- **STRING** → `length="255"` (or smaller if specified, e.g., `length="50"` for codes)
- **INTEGER** → `length="10"` (standard for all integers)
- **TEXT** → `length="255"` (default)
- **LONG** → `length="255"` (default)
- **DATE** → `length="255"` (default)
- **BOOLEAN** → `length="255"` (default)
- **LOCALDATE** → `length="255"` (default)
- **LOCALDATETIME** → `length="255"` (default)

**Default length for all types: `length="255"`** (except INTEGER which uses `length="10"`)

**NEVER create ANY field without a length attribute - this is a project requirement.**

**Examples:**
```xml
<!-- CORRECT - ALL fields have length attribute -->
<field type="STRING" length="255" name="nom" nullable="false" collection="false"/>
<field type="STRING" length="50" name="code" nullable="false" collection="false"/>
<field type="INTEGER" length="10" name="age" nullable="false" collection="false"/>
<field type="INTEGER" length="10" name="count" nullable="false" collection="false"/>
<field type="TEXT" length="255" name="description" nullable="true" collection="false"/>
<field type="LONG" length="255" name="persistenceId" nullable="false" collection="false"/>
<field type="BOOLEAN" length="255" name="actif" nullable="false" collection="false"/>
<field type="LOCALDATE" length="255" name="dateEmission" nullable="false" collection="false"/>
<field type="LOCALDATETIME" length="255" name="dateCreation" nullable="false" collection="false"/>

<!-- WRONG - Missing length attribute -->
<field type="STRING" name="nom" nullable="false" collection="false"/>
<field type="INTEGER" name="age" nullable="false" collection="false"/>
<field type="TEXT" name="description" nullable="true" collection="false"/>
<field type="BOOLEAN" name="actif" nullable="false" collection="false"/>
```

**Default length values to use:**
- STRING: `length="255"` (or smaller if specified, e.g., `length="50"` for codes)
- INTEGER: `length="10"` (standard for all integers)
- ALL other types: `length="255"` (default for all)

### 2. Field Descriptions Mandatory

**CRITICAL** - **ALL fields MUST have business-friendly descriptions** that non-technical business owners can understand.

See [BDM_FIELD_DESCRIPTION_RULES.md](BDM_FIELD_DESCRIPTION_RULES.md) for complete guidelines.

**Every field must include a `<description>` element:**
```xml
<field type="STRING" length="255" name="emploi" nullable="false" collection="false">
    <description>Intitulé du poste ou de l'emploi recherché (ex: Gestionnaire prestations, Conseiller allocataire)</description>
</field>
```

**Description requirements:**
- ✅ Plain business language (no technical jargon)
- ✅ Explains purpose and context
- ✅ Includes examples for coded values
- ✅ 50-150 characters recommended
- ✅ In French for this project
- ❌ No "field", "column", "FK", "boolean" terms
- ❌ No technical database terminology

**Examples:**

```xml
<!-- GOOD - Business-friendly -->
<field type="STRING" length="50" name="statut" nullable="false" collection="false">
    <description>État d'avancement de la demande dans le circuit de validation (Brouillon, En cours, Validé, Refusé)</description>
</field>

<field type="LOCALDATE" length="255" name="dateEmission" nullable="false" collection="false">
    <description>Date à laquelle la demande de recrutement a été créée par la direction</description>
</field>

<!-- BAD - Too technical -->
<field type="STRING" length="50" name="statut" nullable="false" collection="false">
    <description>Status field for workflow</description>
</field>
```

### 3. Avoid Blacklisted Field Names

**CRITICAL** - Never use reserved/blacklisted field names. See [BDM_FIELD_NAME_BLACKLIST.md](BDM_FIELD_NAME_BLACKLIST.md) for complete list.

**Forbidden field names:**
- `description` → Use `descriptionTexte`, `descriptionAction`, `descriptionDocument`, `commentaire`, `libelle`
- `persistenceId` → Reserved by Bonita (auto-generated)
- `persistenceVersion` → Reserved by Bonita (auto-generated)
- `class` → Java reserved keyword
- `type` → Conflicts with BDM type system
- Java reserved keywords: `new`, `return`, `extends`, `implements`, `package`, etc.

**Rename conflicts with context-specific alternatives:**
```xml
<!-- WRONG - Reserved name -->
<field type="TEXT" length="255" name="description" nullable="true" collection="false"/>

<!-- CORRECT - Context-specific name -->
<field type="TEXT" length="255" name="descriptionAction" nullable="false" collection="false">
    <description>Explication détaillée de l'action effectuée pour l'audit et la traçabilité</description>
</field>
<field type="TEXT" length="255" name="descriptionDocument" nullable="true" collection="false">
    <description>Commentaire libre décrivant le contenu ou l'objet du document joint</description>
</field>
```

### 4. Use AGGREGATION/COMPOSITION

**CRITICAL** use AGGREGATION or COMPOSITION for relationships, and not simple fields with LONG foreign keys

### 5. Valid Field Types Only

Use only these types:
- STRING (with **MANDATORY** length attribute)
- TEXT (no length limit)
- INTEGER (with **MANDATORY** length attribute)
- LONG
- DATE
- BOOLEAN
- LOCALDATE
- LOCALDATETIME

### 6. Avoid Duplicate Query Names

Bonita auto-generates queries for fields with unique constraints:
- Field `code` with unique constraint → auto-generates `findByCode`
- Field `numeroFEB` with unique constraint → auto-generates `findByNumeroFEB`

**DO NOT create custom queries with these names.**

Use descriptive names instead:
- `findActiveDirections`
- `findFEBByDirection`
- `findAllFEB`
- `findHistoriqueByFEB`

### 7. Index Name Length Limit (≤20 characters)

**CRITICAL** - **ALL index names MUST be 20 characters or less**

This is a **MANDATORY** requirement. See [BDM_INDEX_NAME_RULES.md](BDM_INDEX_NAME_RULES.md) for complete rules.

**Valid index names (≤20 chars):**
```xml
<!-- Good - 14 characters -->
<index name="IDX_FEB_statut">

<!-- Good - At limit (20 chars) -->
<index name="IDX_FEB_dateEmission">

<!-- Good - Abbreviated (16 chars) -->
<index name="IDX_valid_statut">

<!-- Good - Short form (14 chars) -->
<index name="IDX_user_actif">
```

**Invalid index names (>20 chars):**
```xml
<!-- BAD - 26 characters -->
<index name="IDX_historique_utilisateur">

<!-- BAD - 25 characters -->
<index name="IDX_utilisateur_direction">

<!-- BAD - 24 characters -->
<index name="IDX_FEB_createurUsername">
```

**Abbreviation guidelines:**
- `validation` → `valid`
- `historique` → `histo`
- `utilisateur` → `user`
- `document` → `doc`
- `createurUsername` → `createur`

**Pattern:** `IDX_{entity}_{field}` with total length ≤ 20

### 8. Proper Namespace

Root element must use:
```xml
<businessObjectModel xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0" modelVersion="1.0">
```

### 9. Qualified Names

All business objects must have fully qualified names:
```xml
<businessObject qualifiedName="com.company.project.model.EntityName">
```

## Example BOM Structure

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<businessObjectModel xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0" modelVersion="1.0">
  <businessObjects>
    <businessObject qualifiedName="com.company.model.Direction">
      <fields>
        <field type="STRING" length="50" name="code" nullable="false" collection="false"/>
        <field type="STRING" length="255" name="libelle" nullable="false" collection="false"/>
        <field type="BOOLEAN" name="active" nullable="true" collection="false"/>
      </fields>
      <uniqueConstraints>
        <uniqueConstraint name="UK_code">
          <fieldNames>
            <fieldName>code</fieldName>
          </fieldNames>
        </uniqueConstraint>
      </uniqueConstraints>
      <queries>
        <!-- Don't create findByCode - auto-generated -->
        <query name="findActiveDirections"
               content="SELECT d FROM Direction d WHERE d.active = true ORDER BY d.libelle"
               returnType="com.company.model.Direction">
          <queryParameters/>
        </query>
      </queries>
      <indexes>
        <index name="IDX_active">
          <fieldNames>
            <fieldName>active</fieldName>
          </fieldNames>
        </index>
      </indexes>
    </businessObject>

    <businessObject qualifiedName="com.company.model.FicheExpressionBesoin">
      <fields>
        <field type="STRING" length="50" name="numeroFEB" nullable="false" collection="false"/>
        <field type="LOCALDATE" name="dateEmission" nullable="false" collection="false"/>
        <!-- Foreign key to Direction -->
        <field type="LONG" name="directionPersistenceId" nullable="false" collection="false"/>
      </fields>
      <uniqueConstraints>
        <uniqueConstraint name="UK_numeroFEB">
          <fieldNames>
            <fieldName>numeroFEB</fieldName>
          </fieldNames>
        </uniqueConstraint>
      </uniqueConstraints>
      <queries>
        <query name="findFEBByDirection"
               content="SELECT f FROM FicheExpressionBesoin f WHERE f.directionPersistenceId = :directionId ORDER BY f.dateEmission DESC"
               returnType="com.company.model.FicheExpressionBesoin">
          <queryParameters>
            <queryParameter name="directionId" className="java.lang.Long"/>
          </queryParameters>
        </query>
      </queries>
      <indexes>
        <index name="IDX_FEB_direction">
          <fieldNames>
            <fieldName>directionPersistenceId</fieldName>
          </fieldNames>
        </index>
      </indexes>
    </businessObject>
  </businessObjects>
</businessObjectModel>
```

## Common Errors and Solutions

### Error: "Missing field description" or "Field description required"
**Cause**: Field without `<description>` element
**Solution**: Add business-friendly description to every field
```xml
<!-- WRONG - No description -->
<field type="STRING" length="255" name="emploi" nullable="false" collection="false"/>

<!-- CORRECT - With description -->
<field type="STRING" length="255" name="emploi" nullable="false" collection="false">
    <description>Intitulé du poste ou de l'emploi recherché (ex: Gestionnaire prestations, Conseiller allocataire)</description>
</field>
```
**See:** [BDM_FIELD_DESCRIPTION_RULES.md](BDM_FIELD_DESCRIPTION_RULES.md) for guidelines.

### Error: "Field name 'description' is reserved" or Import fails with field conflicts
**Cause**: Using reserved/blacklisted field name
**Solution**: Rename field with context-specific alternative
```xml
<!-- WRONG - Reserved name -->
<field type="TEXT" length="255" name="description" nullable="true" collection="false"/>

<!-- CORRECT - Context-specific names -->
<field type="TEXT" length="255" name="descriptionAction" nullable="false" collection="false"/>
<field type="TEXT" length="255" name="descriptionDocument" nullable="true" collection="false"/>
<field type="TEXT" length="255" name="commentaire" nullable="true" collection="false"/>
```
**See:** [BDM_FIELD_NAME_BLACKLIST.md](BDM_FIELD_NAME_BLACKLIST.md) for complete list of forbidden names.

### Error: "Missing length attribute" or Import fails in Bonita Studio
**Cause**: ANY field without `length` attribute
**Solution**: Add `length` attribute to ALL fields of ALL types
```xml
<!-- CORRECT - ALL fields have length -->
<field type="STRING" length="255" name="nom" nullable="false" collection="false"/>
<field type="INTEGER" length="10" name="count" nullable="false" collection="false"/>
<field type="TEXT" length="255" name="description" nullable="true" collection="false"/>
<field type="BOOLEAN" length="255" name="actif" nullable="false" collection="false"/>
<field type="LOCALDATE" length="255" name="date" nullable="false" collection="false"/>
```

### Error: "COMPOSITION is not an element of the set"
**Cause**: Using COMPOSITION for relationships
**Solution**: Use LONG fields for foreign keys instead

### Error: "Duplicate query name 'findByCode'"
**Cause**: Creating query for field with unique constraint
**Solution**: Remove custom query, let Bonita auto-generate it

### Error: "Invalid index name" or "Index name too long"
**Cause**: Index name exceeds 20 characters or contains invalid characters
**Solution**: Abbreviate and keep names ≤ 20 characters
```xml
<!-- WRONG - Too long (26 chars) -->
<index name="IDX_historique_utilisateur">

<!-- CORRECT - Abbreviated (14 chars) -->
<index name="IDX_histo_user">

<!-- WRONG - Too long (24 chars) -->
<index name="IDX_FEB_createurUsername">

<!-- CORRECT - Shortened (16 chars) -->
<index name="IDX_FEB_createur">
```
**See:** [BDM_INDEX_NAME_RULES.md](BDM_INDEX_NAME_RULES.md) for abbreviation guidelines

### Error: "VARCHAR is not a valid type"
**Cause**: Using SQL type instead of Bonita type
**Solution**: Use STRING or TEXT instead

## Next Steps

After generating BOM:
1. Review the generated XML for completeness
2. Import into Bonita Studio to test
3. Use with `/bonita-generate-organization` and `/bonita-generate-process` to create full application

## Notes

- Foreign keys use pattern `{entityName}PersistenceId`
- Collection relationships not supported in Bonita 10.x format - use individual foreign keys
- The skill automatically validates the generated XML
- If validation fails, the file is still created but errors are reported
- BDM package name is extracted from analysis or uses default pattern

# Step 2: Generate BOM XML

Generate the Bonita BDM XML file from extracted entity data.

## ⚠️ CRITICAL REQUIREMENTS - Before Generating Fields

**1. Length Attributes (MANDATORY):**
- **ALL fields of ANY type MUST have `length` attribute** → This is a PROJECT REQUIREMENT
- **STRING fields:** Default `length="255"` (or smaller if specified)
- **INTEGER fields:** Standard `length="10"`
- **ALL other types (TEXT, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME):** Default `length="255"`
- **NEVER create ANY field without a length attribute - NO EXCEPTIONS**

**2. Field Descriptions (MANDATORY):**
- **ALL fields MUST have business-friendly `<description>` element**
- **Check:** [BDM_FIELD_DESCRIPTION_RULES.md](../BDM_FIELD_DESCRIPTION_RULES.md)
- **Requirements:**
  - Plain business language (no technical jargon)
  - Explains purpose and context
  - Includes examples for coded values
  - 50-150 characters recommended
  - In French for this project
- **Examples:**
  ```xml
  <field type="STRING" length="50" name="statut" nullable="false" collection="false">
      <description>État d'avancement de la demande dans le circuit de validation (Brouillon, En cours, Validé)</description>
  </field>
  ```

**3. Field Name Blacklist (MANDATORY):**
- **NEVER use reserved/blacklisted field names**
- **Check against:** [BDM_FIELD_NAME_BLACKLIST.md](../BDM_FIELD_NAME_BLACKLIST.md)
- **Forbidden names:** `description`, `persistenceId`, `persistenceVersion`, `class`, `type`, Java keywords
- **Rename conflicts:** Use context-specific alternatives
  - `description` → `descriptionAction`, `descriptionDocument`, `descriptionProfil`, `commentaire`
  - `type` → `typeObjet`, `categorie`, `nature`

## Input

- Extracted entity data from Step 1
- Output path (from `--output` parameter or default `docs/artifacts/bom.xml`)

## Process

1. Create output directory if needed
2. Generate XML structure with proper namespace
3. For each entity, generate business object element
4. Convert relationships to LONG foreign keys
5. Generate queries (avoiding duplicates)
6. Add indexes for performance
7. Write XML to file

## XML Structure

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<businessObjectModel xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0" modelVersion="1.0">
  <businessObjects>
    <!-- Business objects here -->
  </businessObjects>
</businessObjectModel>
```

## Creating Output Directory

```bash
# Ensure directory exists
mkdir -p "$(dirname "$output_path")"
```

## Generating Business Objects

For each entity from Step 1:

### 1. Business Object Element

```xml
<businessObject qualifiedName="com.cnaf.recrutement.model.FicheExpressionBesoin">
  <description>Represents a recruitment request form</description>
  <fields>
    <!-- Fields here -->
  </fields>
  <uniqueConstraints>
    <!-- Constraints here -->
  </uniqueConstraints>
  <queries>
    <!-- Queries here -->
  </queries>
  <indexes>
    <!-- Indexes here -->
  </indexes>
</businessObject>
```

### 2. Fields Section

For each field in the entity:

**All fields MUST have length attribute - examples:**

```xml
<!-- STRING fields -->
<field type="STRING" length="255" name="nom" nullable="false" collection="false"/>
<field type="STRING" length="50" name="code" nullable="false" collection="false"/>

<!-- INTEGER fields -->
<field type="INTEGER" length="10" name="montant" nullable="true" collection="false"/>
<field type="INTEGER" length="10" name="count" nullable="false" collection="false"/>

<!-- Other types - ALL must have length="255" -->
<field type="TEXT" length="255" name="description" nullable="true" collection="false"/>
<field type="LONG" length="255" name="persistenceId" nullable="false" collection="false"/>
<field type="BOOLEAN" length="255" name="actif" nullable="true" collection="false"/>
<field type="LOCALDATE" length="255" name="dateEmission" nullable="false" collection="false"/>
<field type="LOCALDATETIME" length="255" name="dateCreation" nullable="false" collection="false"/>
```

**CRITICAL:** ALL fields MUST have `length` attribute. Default to `length="255"` for all types except INTEGER which uses `length="10"`.

**Foreign key field (for relationships):**
```xml
<field type="LONG" name="directionPersistenceId" nullable="false" collection="false"/>
```

**Field attributes:**
- `type` - Bonita field type (required)
- `name` - Field name in camelCase (required)
- `nullable` - "true" or "false" (required)
- `collection` - Always "false" for Bonita 10.x (required)
- `length` - **MANDATORY for ALL field types** (PROJECT REQUIREMENT)
  - **STRING fields:** Default `length="255"` (or smaller if specified: `length="50"` for codes, `length="100"` for identifiers)
  - **INTEGER fields:** Standard `length="10"` (use for all INTEGER fields)
  - **ALL other types (TEXT, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME):** Default `length="255"`
  - **NEVER omit the length attribute for any field type**

### 3. Unique Constraints Section

For each unique field:

```xml
<uniqueConstraints>
  <uniqueConstraint name="UK_numeroFEB">
    <fieldNames>
      <fieldName>numeroFEB</fieldName>
    </fieldNames>
  </uniqueConstraint>
  <uniqueConstraint name="UK_code">
    <fieldNames>
      <fieldName>code</fieldName>
    </fieldNames>
  </uniqueConstraint>
</uniqueConstraints>
```

**Constraint naming:** `UK_{fieldName}` or `UK_{EntityName}_{fieldName}`

**Empty if no unique fields:**
```xml
<uniqueConstraints/>
```

### 4. Queries Section

**CRITICAL RULE:** Do NOT create queries for fields with unique constraints - Bonita auto-generates these.

**Auto-generated queries to AVOID:**
- Field `code` with unique constraint → `findByCode` (auto-generated)
- Field `numeroFEB` with unique constraint → `findByNumeroFEB` (auto-generated)
- Field `email` with unique constraint → `findByEmail` (auto-generated)

**Safe custom queries:**

**Query for relationship navigation:**
```xml
<query name="findFEBByDirection"
       content="SELECT f FROM FicheExpressionBesoin f WHERE f.directionPersistenceId = :directionId ORDER BY f.dateEmission DESC"
       returnType="com.cnaf.recrutement.model.FicheExpressionBesoin">
  <queryParameters>
    <queryParameter name="directionId" className="java.lang.Long"/>
  </queryParameters>
</query>
```

**Query with complex conditions:**
```xml
<query name="findActiveDirections"
       content="SELECT d FROM Direction d WHERE d.active = true ORDER BY d.libelle"
       returnType="com.cnaf.recrutement.model.Direction">
  <queryParameters/>
</query>
```

**Query with multiple parameters:**
```xml
<query name="findFEBByStatutAndDirection"
       content="SELECT f FROM FicheExpressionBesoin f WHERE f.statut = :statut AND f.directionPersistenceId = :directionId ORDER BY f.dateEmission DESC"
       returnType="com.cnaf.recrutement.model.FicheExpressionBesoin">
  <queryParameters>
    <queryParameter name="statut" className="java.lang.String"/>
    <queryParameter name="directionId" className="java.lang.Long"/>
  </queryParameters>
</query>
```

**Query with no parameters:**
```xml
<query name="findAllFEB"
       content="SELECT f FROM FicheExpressionBesoin f ORDER BY f.dateEmission DESC"
       returnType="com.cnaf.recrutement.model.FicheExpressionBesoin">
  <queryParameters/>
</query>
```

**Query parameter types:**
- String → `java.lang.String`
- Integer → `java.lang.Integer`
- Long → `java.lang.Long`
- Boolean → `java.lang.Boolean`
- Date → `java.util.Date`
- LocalDate → `java.time.LocalDate`
- LocalDateTime → `java.time.LocalDateTime`

**Empty if no custom queries:**
```xml
<queries/>
```

### 5. Indexes Section

Add indexes for fields frequently used in queries:

**Single field index:**
```xml
<index name="IDX_statut">
  <fieldNames>
    <fieldName>statut</fieldName>
  </fieldNames>
</index>
```

**Foreign key index:**
```xml
<index name="IDX_febId_doc">
  <fieldNames>
    <fieldName>ficheExpressionBesoinPersistenceId</fieldName>
  </fieldNames>
</index>
```

**Multiple field index:**
```xml
<index name="IDX_statut_date">
  <fieldNames>
    <fieldName>statut</fieldName>
    <fieldName>dateEmission</fieldName>
  </fieldNames>
</index>
```

**Index naming rules:**
- **MANDATORY:** Names must be ≤ 20 characters (see [BDM_INDEX_NAME_RULES.md](../BDM_INDEX_NAME_RULES.md))
- Keep names short and SQL-safe
- Use pattern `IDX_{entity}_{field}` with total length ≤ 20
- Use abbreviations when needed:
  - `validation` → `valid`
  - `utilisateur` → `user`
  - `historique` → `histo`
  - `createurUsername` → `createur`
- Examples:
  - ✓ `IDX_FEB_statut` (14 chars)
  - ✓ `IDX_valid_statut` (16 chars)
  - ✓ `IDX_FEB_dateEmission` (20 chars - at limit)
  - ❌ `IDX_historique_utilisateur` (26 chars - TOO LONG)
  - ❌ `IDX_FEB_createurUsername` (24 chars - TOO LONG)

**When to add indexes:**
- Foreign key fields (for join performance)
- Fields used in WHERE clauses (status, dates)
- Fields used in ORDER BY
- Fields frequently queried

**Empty if no indexes:**
```xml
<indexes/>
```

## Handling Relationships

### Many-to-One (Child → Parent)

Example: FEB belongs to Direction

**In child entity (FEB):**
```xml
<fields>
  <!-- Other fields -->
  <field type="LONG" name="directionPersistenceId" nullable="false" collection="false"/>
</fields>

<queries>
  <!-- Query to find children by parent -->
  <query name="findFEBByDirection"
         content="SELECT f FROM FicheExpressionBesoin f WHERE f.directionPersistenceId = :directionId ORDER BY f.dateEmission DESC"
         returnType="com.cnaf.recrutement.model.FicheExpressionBesoin">
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
```

### One-to-Many (Parent → Children)

Example: FEB has many Documents

**In child entity (Document):**
```xml
<fields>
  <!-- Other fields -->
  <field type="LONG" name="ficheExpressionBesoinPersistenceId" nullable="false" collection="false"/>
</fields>

<queries>
  <query name="findDocumentsByFEB"
         content="SELECT d FROM Document d WHERE d.ficheExpressionBesoinPersistenceId = :febId ORDER BY d.dateAjout DESC"
         returnType="com.cnaf.recrutement.model.Document">
    <queryParameters>
      <queryParameter name="febId" className="java.lang.Long"/>
    </queryParameters>
  </query>
</queries>

<indexes>
  <index name="IDX_febId_doc">
    <fieldNames>
      <fieldName>ficheExpressionBesoinPersistenceId</fieldName>
    </fieldNames>
  </index>
</indexes>
```

**In parent entity (FEB):**
No changes needed. Use query from Document entity to fetch children.

### Many-to-Many

Example: FEB can have multiple Validators, Validator can validate multiple FEBs

**Create join entity (FEBValidateur):**
```xml
<businessObject qualifiedName="com.cnaf.recrutement.model.FEBValidateur">
  <description>Association between FEB and Validator</description>
  <fields>
    <field type="LONG" name="ficheExpressionBesoinPersistenceId" nullable="false" collection="false"/>
    <field type="LONG" name="validateurPersistenceId" nullable="false" collection="false"/>
    <field type="LOCALDATE" name="dateAssignation" nullable="true" collection="false"/>
  </fields>
  <uniqueConstraints>
    <uniqueConstraint name="UK_FEB_Validateur">
      <fieldNames>
        <fieldName>ficheExpressionBesoinPersistenceId</fieldName>
        <fieldName>validateurPersistenceId</fieldName>
      </fieldNames>
    </uniqueConstraint>
  </uniqueConstraints>
  <queries>
    <query name="findValidateursByFEB"
           content="SELECT v FROM FEBValidateur v WHERE v.ficheExpressionBesoinPersistenceId = :febId"
           returnType="com.cnaf.recrutement.model.FEBValidateur">
      <queryParameters>
        <queryParameter name="febId" className="java.lang.Long"/>
      </queryParameters>
    </query>
    <query name="findFEBsByValidateur"
           content="SELECT v FROM FEBValidateur v WHERE v.validateurPersistenceId = :validateurId"
           returnType="com.cnaf.recrutement.model.FEBValidateur">
      <queryParameters>
        <queryParameter name="validateurId" className="java.lang.Long"/>
      </queryParameters>
    </query>
  </queries>
  <indexes>
    <index name="IDX_febId_val">
      <fieldNames>
        <fieldName>ficheExpressionBesoinPersistenceId</fieldName>
      </fieldNames>
    </index>
    <index name="IDX_valId_feb">
      <fieldNames>
        <fieldName>validateurPersistenceId</fieldName>
      </fieldNames>
    </index>
  </indexes>
</businessObject>
```

### Embedded Objects

Example: FEB has validation results (embedded data)

**Option 1: Flatten into parent entity**
```xml
<fields>
  <field type="STRING" length="50" name="validationStatut" nullable="true" collection="false"/>
  <field type="LOCALDATE" name="validationDate" nullable="true" collection="false"/>
  <field type="STRING" length="255" name="validationComment" nullable="true" collection="false"/>
</fields>
```

**Option 2: Create separate entity with foreign key**
```xml
<businessObject qualifiedName="com.cnaf.recrutement.model.ValidationResult">
  <fields>
    <field type="STRING" length="50" name="statut" nullable="false" collection="false"/>
    <field type="LOCALDATE" name="date" nullable="false" collection="false"/>
    <field type="TEXT" name="comment" nullable="true" collection="false"/>
    <field type="LONG" name="ficheExpressionBesoinPersistenceId" nullable="false" collection="false"/>
  </fields>
  <!-- queries and indexes -->
</businessObject>
```

## Complete Entity Example

```xml
<businessObject qualifiedName="com.cnaf.recrutement.model.FicheExpressionBesoin">
  <description>Represents a recruitment request form</description>
  <fields>
    <field type="STRING" length="50" name="numeroFEB" nullable="false" collection="false"/>
    <field type="STRING" length="255" name="niveau" nullable="false" collection="false"/>
    <field type="LOCALDATE" length="255" name="dateEmission" nullable="false" collection="false"/>
    <field type="STRING" length="50" name="statut" nullable="false" collection="false"/>
    <field type="INTEGER" length="10" name="montantBudget" nullable="true" collection="false"/>
    <field type="BOOLEAN" length="255" name="enPause" nullable="true" collection="false"/>
    <field type="LONG" length="255" name="directionPersistenceId" nullable="false" collection="false"/>
    <field type="STRING" length="100" name="createurLogin" nullable="false" collection="false"/>
    <field type="LOCALDATETIME" length="255" name="dateCreation" nullable="false" collection="false"/>
  </fields>
  <uniqueConstraints>
    <uniqueConstraint name="UK_numeroFEB">
      <fieldNames>
        <fieldName>numeroFEB</fieldName>
      </fieldNames>
    </uniqueConstraint>
  </uniqueConstraints>
  <queries>
    <!-- Don't create findByNumeroFEB - auto-generated -->
    <query name="findFEBByDirection"
           content="SELECT f FROM FicheExpressionBesoin f WHERE f.directionPersistenceId = :directionId ORDER BY f.dateEmission DESC"
           returnType="com.cnaf.recrutement.model.FicheExpressionBesoin">
      <queryParameters>
        <queryParameter name="directionId" className="java.lang.Long"/>
      </queryParameters>
    </query>
    <query name="findByCreateur"
           content="SELECT f FROM FicheExpressionBesoin f WHERE f.createurLogin = :login ORDER BY f.dateEmission DESC"
           returnType="com.cnaf.recrutement.model.FicheExpressionBesoin">
      <queryParameters>
        <queryParameter name="login" className="java.lang.String"/>
      </queryParameters>
    </query>
    <query name="findAllFEB"
           content="SELECT f FROM FicheExpressionBesoin f ORDER BY f.dateEmission DESC"
           returnType="com.cnaf.recrutement.model.FicheExpressionBesoin">
      <queryParameters/>
    </query>
  </queries>
  <indexes>
    <index name="IDX_FEB_statut">
      <fieldNames>
        <fieldName>statut</fieldName>
      </fieldNames>
    </index>
    <index name="IDX_FEB_dateEmission">
      <fieldNames>
        <fieldName>dateEmission</fieldName>
      </fieldNames>
    </index>
    <index name="IDX_FEB_direction">
      <fieldNames>
        <fieldName>directionPersistenceId</fieldName>
      </fieldNames>
    </index>
    <index name="IDX_FEB_createur">
      <fieldNames>
        <fieldName>createurLogin</fieldName>
      </fieldNames>
    </index>
  </indexes>
</businessObject>
```

## Writing XML File

1. Format XML with proper indentation (2 or 4 spaces)
2. Use UTF-8 encoding
3. Include XML declaration: `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>`
4. Ensure all tags are properly closed
5. Write to output path

```bash
# Create directory if needed
mkdir -p "$(dirname "$OUTPUT_PATH")"

# Write XML content to file
cat > "$OUTPUT_PATH" << 'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<businessObjectModel xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0" modelVersion="1.0">
  ...
</businessObjectModel>
EOF
```

## Verification Before Step 3

Before proceeding to validation:
- ✅ File created at correct path
- ✅ XML is well-formed
- ✅ All entities included
- ✅ **ALL fields of ALL types have `length` attribute - NO EXCEPTIONS**
  - STRING: `length="255"` or smaller
  - INTEGER: `length="10"`
  - TEXT, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME: `length="255"`
- ✅ **ALL fields have business-friendly `<description>` element - NO EXCEPTIONS**
  - Every field must have description child element
  - Plain business language (no jargon)
  - Explains purpose with examples
  - 50-150 characters recommended
- ✅ **NO blacklisted field names** (check against BDM_FIELD_NAME_BLACKLIST.md)
  - No fields named `description`, `persistenceId`, `persistenceVersion`, `class`, `type`
  - All conflicts renamed with context-specific alternatives
- ✅ No AGGREGATION or COMPOSITION fields (unless using relationField approach)
- ✅ Foreign keys use LONG type with `length="255"` (or relationField for COMPOSITION/AGGREGATION)
- ✅ No duplicate query names
- ✅ **ALL index names are ≤ 20 characters** (MANDATORY)
  - Check each index name length
  - Use abbreviations if needed
  - Pattern: `IDX_{entity}_{field}` ≤ 20 chars
- ✅ Index names are SQL-safe (alphanumeric + underscore only)
- ✅ Proper namespace and model version

## Output

- BOM XML file saved to specified path
- File path and size reported
- Ready for XSD validation in Step 3

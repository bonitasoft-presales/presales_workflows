# Step 6: Generate Bonita BOM XML File

**CRITICAL**: Generate a `bom.xml` file conformant to Bonita 10.x BOM format
**CRITICAL**: always validate file using `.claude/xsd/bom.xsd` xml schema

## Important Note for Bonita 10.x



## Reference
* Read the reference BOM format from `bdm/bom.xml` to understand the structure

## Structure
* Create a new `bom.xml` file in `docs/out/` directory based on analyzed BDM entities
* Use the XML structure with proper namespace:
  - Root element: `<businessObjectModel xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0" modelVersion="1.0">`
  - Each business object should have: qualifiedName, fields, uniqueConstraints, queries, indexes

## Field Mapping
For each BDM entity identified in Step 2:
- Create a `<businessObject>` element with `qualifiedName` (e.g., "com.cnaf.recrutement.model.EntityName")
- Add all attributes as `<field>` elements with proper types:
  * Map String → type="STRING" with length="255" (or appropriate length)
  * Map Integer → type="INTEGER"
  * Map Long → type="LONG"
  * Map Date → type="DATE"
  * Map Boolean → type="BOOLEAN"
  * Map Text → type="TEXT" (no length limit)
  * Map LocalDate → type="LOCALDATE"
  * Map LocalDateTime → type="LOCALDATETIME"

## Relationships - Use Foreign Keys

**For Bonita 10.x, DO NOT use AGGREGATION or COMPOSITION fields.**

Instead, use LONG fields for foreign keys:

**Many-to-One relationships (e.g., FEB has one Direction):**
* Add a LONG field named `{entityName}PersistenceId`
* Example: `directionPersistenceId` (type="LONG")
* Add a query to fetch the related entity by persistenceId

**One-to-Many relationships (e.g., FEB has many Documents):**
* Add a LONG field in the child entity pointing to parent
* Example: In `Document`, add `ficheExpressionBesoinPersistenceId` (type="LONG")
* Add a query in child entity to find all children by parent ID

**Embedded objects (e.g., FEB has validation results):**
* Consider flattening the data into the main entity
* Or create separate entities with Long foreign keys

## Constraints and Queries

### Unique Constraints
- Add `<uniqueConstraints>` if unique fields are identified (e.g., numeroFEB, code)
- Use descriptive constraint names: `UK_{EntityName}_{fieldName}` or `UK_{fieldName}`

### Queries - IMPORTANT RULES

**CRITICAL**: Bonita auto-generates queries for fields with unique constraints. **DO NOT** create custom queries that conflict with these.

**Auto-generated query patterns:**
- Field with unique constraint `code` → auto-generates `findByCode`
- Field with unique constraint `numeroFEB` → auto-generates `findByNumeroFEB`
- Field `statut` → auto-generates `findByStatut`
- Field `acteur` → auto-generates `findByActeur`

**Rules for custom queries:**
1. **Check for unique constraints first** - if a field has a unique constraint, skip creating `findBy{FieldName}` query
2. **Use different query names** - e.g., `findFEBByDirection`, `findAllFEB`, `findActiveDirections`
3. **Complex queries are safe** - queries with multiple conditions, ORDER BY, filtering are fine
4. **Relationship queries** - always create queries for foreign key navigation (e.g., `findByFEB`, `findHistoriqueByFEB`)

**Examples of queries to AVOID (conflicts with auto-generated):**
```xml
<!-- BAD - conflicts with auto-generated query -->
<query name="findByCode" content="SELECT d FROM Direction d WHERE d.code = :code"/>
<query name="findByNumeroFEB" content="SELECT f FROM FicheExpressionBesoin f WHERE f.numeroFEB = :numeroFEB"/>
<query name="findByStatut" content="SELECT f FROM FicheExpressionBesoin f WHERE f.statut = :statut"/>
<query name="findByActeur" content="SELECT a FROM ActionHistorique a WHERE a.acteur = :acteur"/>
```

**Examples of GOOD custom queries:**
```xml
<!-- GOOD - different names, complex queries, or relationships -->
<query name="findActiveDirections" content="SELECT d FROM Direction d WHERE d.active = true ORDER BY d.libelle"/>
<query name="findFEBByDirection" content="SELECT f FROM FicheExpressionBesoin f WHERE f.directionPersistenceId = :directionId ORDER BY f.dateEmission DESC"/>
<query name="findByCreateur" content="SELECT f FROM FicheExpressionBesoin f WHERE f.createurLogin = :login ORDER BY f.dateEmission DESC"/>
<query name="findAllFEB" content="SELECT f FROM FicheExpressionBesoin f ORDER BY f.dateEmission DESC"/>
<query name="findHistoriqueByFEB" content="SELECT a FROM ActionHistorique a WHERE a.ficheExpressionBesoinPersistenceId = :febId ORDER BY a.dateAction DESC"/>
```

- **Add queries to fetch related entities** using persistenceId fields
- Set nullable="false" for mandatory fields, nullable="true" for optional fields

### Indexes - IMPORTANT NAMING RULES

**CRITICAL**: Index names must be valid SQL identifiers. Avoid entity name prefixes that could cause conflicts.

**Index naming rules:**
1. **Keep names simple** - use `IDX_{fieldName}` pattern
2. **Avoid entity name prefixes** - don't use `IDX_{EntityName}_{fieldName}`
3. **For foreign keys** - use descriptive but short names like `IDX_febId` or `IDX_febId_action`
4. **Be consistent** - use same naming pattern throughout the BDM

**Examples of INVALID index names:**
```xml
<!-- BAD - contains entity name that causes SQL identifier conflicts -->
<index name="IDX_ActionHistorique_dateAction">  <!-- INVALID -->
<index name="IDX_ActionHistorique_febId">       <!-- INVALID -->
<index name="IDX_Document_febId">               <!-- INVALID -->
```

**Examples of VALID index names:**
```xml
<!-- GOOD - simple, short, valid SQL identifiers -->
<index name="IDX_dateAction">
  <fieldNames>
    <fieldName>dateAction</fieldName>
  </fieldNames>
</index>

<index name="IDX_febId_action">
  <fieldNames>
    <fieldName>ficheExpressionBesoinPersistenceId</fieldName>
  </fieldNames>
</index>

<index name="IDX_FEB_statut">
  <fieldNames>
    <fieldName>statut</fieldName>
  </fieldNames>
</index>

<index name="IDX_FEB_createurLogin">
  <fieldNames>
    <fieldName>createurLogin</fieldName>
  </fieldNames>
</index>
```

**When to add indexes:**
- Fields frequently used in WHERE clauses (status, dates, creator)
- Foreign key fields (for join performance)
- Fields used in ORDER BY clauses
- Do NOT over-index - only add indexes for fields that will be frequently queried

## Example - Bonita 10.x Compatible

relation field example:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<businessObjectModel xmlns="http://documentation.bonitasoft.com/bdm-xml-schema/1.0" modelVersion="1.0">
    <businessObjects>
        <businessObject qualifiedName="com.company.model.BusinessObject">
            <description>zedzd</description>
            <fields>
                <field type="STRING" length="255" name="myAttribute" nullable="true" collection="false"/>
            </fields>
            <uniqueConstraints/>
            <queries/>
            <indexes/>
        </businessObject>
        <businessObject qualifiedName="com.company.model.BusinessObject2">
            <fields>
                <relationField type="COMPOSITION" reference="com.company.model.BusinessObject" fetchType="LAZY" name="myAttribute" nullable="true" collection="false"/>
                <field type="STRING" length="255" name="myAttribute1" nullable="true" collection="false"/>
            </fields>
            <uniqueConstraints/>
            <queries/>
            <indexes/>
        </businessObject>
        <businessObject qualifiedName="com.company.model.BusinessObject3">
            <fields>
                <relationField type="COMPOSITION" reference="com.company.model.BusinessObject2" fetchType="EAGER" name="myAttribute" nullable="true" collection="false"/>
            </fields>
            <uniqueConstraints/>
            <queries/>
            <indexes/>
        </businessObject>
    </businessObjects>
</businessObjectModel>

```


```xml
<!-- Main entity with foreign key fields -->
<businessObject qualifiedName="com.cnaf.recrutement.model.FicheExpressionBesoin">
  <fields>
    <field type="STRING" length="50" name="numeroFEB" nullable="false" collection="false"/>
    <field type="STRING" length="255" name="niveau" nullable="false" collection="false"/>
    <field type="LOCALDATE" name="dateEmission" nullable="false" collection="false"/>
    <field type="BOOLEAN" name="enPause" nullable="true" collection="false"/>

  </fields>

  <uniqueConstraints>
    <uniqueConstraint name="UK_numeroFEB">
      <fieldNames>
        <fieldName>numeroFEB</fieldName>
      </fieldNames>
    </uniqueConstraint>
  </uniqueConstraints>

  <queries>
    <!-- NOTE: Don't create findByNumeroFEB - auto-generated by unique constraint -->

    <!-- Custom query with different name - OK -->
    <query name="findFEBByDirection" content="SELECT f FROM FicheExpressionBesoin f WHERE f.directionPersistenceId = :directionId ORDER BY f.dateEmission DESC" returnType="com.cnaf.recrutement.model.FicheExpressionBesoin">
      <queryParameters>
        <queryParameter name="directionId" className="java.lang.Long"/>
      </queryParameters>
    </query>

    <!-- Query for relationship navigation - OK -->
    <query name="findAllFEB" content="SELECT f FROM FicheExpressionBesoin f ORDER BY f.dateEmission DESC" returnType="com.cnaf.recrutement.model.FicheExpressionBesoin">
      <queryParameters/>
    </query>
  </queries>

  <indexes>
    <!-- Use simple names without entity prefix -->
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
  </indexes>
</businessObject>

<!-- Child entity with foreign key to parent -->
<businessObject qualifiedName="com.cnaf.recrutement.model.Document">
  <fields>
    <field type="STRING" length="255" name="nom" nullable="false" collection="false"/>
    <field type="TEXT" name="description" nullable="true" collection="false"/>
    <field type="LOCALDATETIME" name="dateAjout" nullable="false" collection="false"/>

    <!-- Foreign key to parent FEB -->
    <field type="LONG" name="ficheExpressionBesoinPersistenceId" nullable="false" collection="false"/>
  </fields>

  <uniqueConstraints/>

  <queries>
    <!-- Query for relationship navigation - OK -->
    <query name="findDocumentsByFEB" content="SELECT d FROM Document d WHERE d.ficheExpressionBesoinPersistenceId = :febId ORDER BY d.dateAjout DESC" returnType="com.cnaf.recrutement.model.Document">
      <queryParameters>
        <queryParameter name="febId" className="java.lang.Long"/>
      </queryParameters>
    </query>
  </queries>

  <indexes>
    <!-- Index on foreign key for join performance -->
    <index name="IDX_febId_doc">
      <fieldNames>
        <fieldName>ficheExpressionBesoinPersistenceId</fieldName>
      </fieldNames>
    </index>
  </indexes>
</businessObject>
```

## Migration Notes

If the analyzed requirements show relationships:
1. **Identify the relationship type** (one-to-one, one-to-many, many-to-many)
2. **For one-to-many:** Add Long field in child entity
3. **For many-to-one:** Add Long field in parent entity
4. **For many-to-many:** Create a join/association entity with two Long fields
5. **Add queries** but keep in mind autogenerated queries

## Finalization
* Save the file as `docs/out/bom.xml`
* Validate the XML structure is well-formed
* Confirm file creation and provide path

## Critical Checklist Before Saving

Before finalizing the BOM file, verify:

1. **✅ No AGGREGATION or COMPOSITION fields** - Only use LONG foreign keys for relationships
2. **✅ No duplicate query names** - Don't create queries for fields with unique constraints
3. **✅ Valid index names** - Use simple names without entity prefixes (avoid `IDX_EntityName_field`)
4. **✅ Foreign keys properly named** - Use pattern `{entityName}PersistenceId` (e.g., `directionPersistenceId`)
5. **✅ Relationship queries created** - Add queries to navigate from child to parent using foreign keys
6. **✅ Proper field types** - Only use valid Bonita 10.x types (STRING, TEXT, INTEGER, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME, etc.)

These rules prevent build failures and ensure Bonita 10.x compatibility.

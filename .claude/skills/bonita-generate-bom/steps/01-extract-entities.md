# Step 1: Extract BDM Entities from Analysis Document

Extract Business Data Model entity definitions from the analysis document.

## Input

- Analysis document path (from `--input` parameter or most recent .adoc in `docs/out/`)

## Process

1. Find most recent analysis document if not specified
2. Read the analysis document (AsciiDoc format)
3. Locate the BDM/Data Model section
4. Extract entity definitions with all attributes
5. Parse field types and map to Bonita types
6. Identify relationships between entities
7. Identify unique constraints (unique fields)
8. Extract any business rules related to data

## Finding the Analysis Document

If `--input` not provided:
```bash
# Find most recent .adoc file in docs/out/
ls -t docs/out/*.adoc | head -1
```

## Locating BDM Section

The analysis document typically contains a section titled one of:
- "Data Model"
- "Business Data Model"
- "BDM"
- "Modèle de données"
- "Entités métier"

Look for AsciiDoc section markers:
```asciidoc
== Business Data Model
== Data Model
=== BDM Entities
```

## Extracting Entity Information

For each entity found, extract:

### 1. Entity Name
- Usually a header (=== EntityName) or bold text
- Convert to PascalCase if needed
- Example: "Fiche Expression Besoin" → "FicheExpressionBesoin"

### 2. Entity Description
- Paragraph describing the entity's purpose
- Use for `<description>` element in XML

### 3. Fields/Attributes

Look for tables or lists describing fields:

**Table format:**
| Field Name | Type | Description | Required | Unique |
|------------|------|-------------|----------|--------|
| numeroFEB | String(50) | FEB number | Yes | Yes |
| dateEmission | Date | Emission date | Yes | No |

**List format:**
```
- numeroFEB (String 50) - FEB number, required, unique
- dateEmission (Date) - Emission date, required
- statut (String) - Status (DRAFT, SUBMITTED, VALIDATED)
- montant (Integer) - Amount in euros
```

### 4. Field Type Mapping

Map analysis types to Bonita field types:

| Analysis Type | Bonita Type | Length Required | Default Length | Notes |
|---------------|-------------|-----------------|----------------|-------|
| String, Text, Texte | STRING | **YES** | **255** | `length="255"` or smaller (e.g., `length="50"` for codes) |
| Long Text, Description | TEXT | **YES** | **255** | `length="255"` |
| Integer, Int, Entier | INTEGER | **YES** | **10** | `length="10"` |
| Long | LONG | **YES** | **255** | `length="255"` (large numbers, foreign keys) |
| Date | DATE | **YES** | **255** | `length="255"` (legacy date type) |
| LocalDate | LOCALDATE | **YES** | **255** | `length="255"` (preferred date type) |
| LocalDateTime, DateTime | LOCALDATETIME | **YES** | **255** | `length="255"` (date with time) |
| Boolean, Bool | BOOLEAN | **YES** | **255** | `length="255"` (true/false) |
| Decimal, Double, Float | DOUBLE | **YES** | **255** | `length="255"` (decimal numbers) |

**⚠️ CRITICAL PROJECT REQUIREMENT:**
- **ALL field types MUST have length attributes** - NO EXCEPTIONS
- **Default length: `length="255"`** for all types except INTEGER which uses `length="10"`
- **NEVER create ANY field without a length attribute**

### 5. Relationships

Identify relationships described in the analysis:

**One-to-Many:**
- "FEB has many Documents"
- "Direction contains multiple FEBs"
- "Employee has history entries"

**Many-to-One:**
- "FEB belongs to a Direction"
- "Document is attached to a FEB"
- "Action performed by a User"

**Many-to-Many:**
- "FEB can have multiple Validators"
- "User can be assigned to multiple FEBs"

**Embedded Objects:**
- "FEB has validation results (nested object)"
- "Address embedded in Employee"

### 6. Constraints

Identify unique fields:
- Fields marked as "unique"
- Primary business identifiers (code, reference number)
- Email addresses
- Registration numbers

Examples:
- `numeroFEB` - unique identifier
- `code` - unique direction code
- `email` - unique user email

### 7. Business Rules

Extract rules that affect data structure:
- Validation rules (formats, ranges)
- Calculated fields
- Status transitions
- Required fields based on conditions

## Data Structure

Store extracted information in a structured format:

```javascript
{
  "entities": [
    {
      "name": "FicheExpressionBesoin",
      "qualifiedName": "com.cnaf.recrutement.model.FicheExpressionBesoin",
      "description": "Represents a recruitment request form",
      "fields": [
        {
          "name": "numeroFEB",
          "type": "STRING",
          "length": 50,
          "nullable": false,
          "unique": true,
          "description": "Unique FEB number"
        },
        {
          "name": "dateEmission",
          "type": "LOCALDATE",
          "length": 255,
          "nullable": false,
          "unique": false,
          "description": "Date when FEB was created"
        },
        {
          "name": "statut",
          "type": "STRING",
          "length": 50,
          "nullable": false,
          "unique": false,
          "description": "Current status"
        }
      ],
      "relationships": [
        {
          "type": "many-to-one",
          "targetEntity": "Direction",
          "description": "FEB belongs to a Direction",
          "foreignKeyField": "directionPersistenceId"
        }
      ],
      "queries": [
        {
          "name": "findFEBByDirection",
          "description": "Find all FEBs for a direction",
          "hasParameters": true
        }
      ]
    },
    {
      "name": "Direction",
      "qualifiedName": "com.cnaf.recrutement.model.Direction",
      "description": "Organizational direction/department",
      "fields": [
        {
          "name": "code",
          "type": "STRING",
          "length": 50,
          "nullable": false,
          "unique": true
        },
        {
          "name": "libelle",
          "type": "STRING",
          "length": 255,
          "nullable": false,
          "unique": false
        }
      ],
      "relationships": [],
      "queries": []
    }
  ],
  "packageName": "com.cnaf.recrutement.model"
}
```

## Determining Package Name

Extract or construct package name:
1. Look for explicit package name in analysis
2. Use project/organization identifiers from document
3. Follow pattern: `com.{organization}.{project}.model`
4. Default: `com.company.model`

Examples:
- CNAF Recrutement → `com.cnaf.recrutement.model`
- Acme HR System → `com.acme.hr.model`

## Handling Missing Information

If information is incomplete:
1. **Missing field type**: Default to STRING with `length="255"`
2. **Missing nullable**: Default to true (optional)
3. **Missing length for ANY field type**: **ALWAYS apply these defaults:**
   - **STRING**: `length="255"` (or smaller if specified)
   - **INTEGER**: `length="10"`
   - **ALL other types**: `length="255"`
4. **Missing description**: Leave empty
5. **Ambiguous relationship**: Use many-to-one with foreign key

**⚠️ CRITICAL PROJECT REQUIREMENT:**
- **Never extract or plan ANY field without a length value**
- **ALL field types MUST have length attributes in the final XML**
- **This applies to STRING, INTEGER, TEXT, LONG, DATE, BOOLEAN, LOCALDATE, LOCALDATETIME, and all other types**

## Common Patterns to Recognize

### Status/State Fields
Usually STRING with fixed values:
```
statut: DRAFT, IN_PROGRESS, SUBMITTED, VALIDATED, REJECTED
```

### Audit Fields
Common in most entities:
```
- createurLogin (STRING) - Who created
- dateCreation (LOCALDATETIME) - When created
- modificateurLogin (STRING) - Who modified
- dateModification (LOCALDATETIME) - When modified
```

### Reference Numbers
Usually STRING with unique constraint:
```
- numeroFEB (STRING 50, unique)
- matricule (STRING 20, unique)
- referenceCommande (STRING 30, unique)
```

## Output

Structured data containing:
- List of entities with fields
- Field types mapped to Bonita types
- Relationships identified with foreign key names
- Unique constraints identified
- Package name determined

This data will be used in Step 2 to generate the BOM XML.

## Example Extraction

From analysis text:
```
=== Fiche Expression Besoin (FEB)

The FEB represents a recruitment request. Each FEB has:
- numeroFEB (unique identifier, string 50 chars)
- dateEmission (creation date)
- statut (status: DRAFT, SUBMITTED, VALIDATED, REJECTED)
- montantBudget (budget amount in euros)
- directionDemandeur (reference to Direction)

A FEB can have multiple documents attached.
```

Extracted structure:
```javascript
{
  "name": "FicheExpressionBesoin",
  "fields": [
    {"name": "numeroFEB", "type": "STRING", "length": 50, "nullable": false, "unique": true},
    {"name": "dateEmission", "type": "LOCALDATE", "length": 255, "nullable": false, "unique": false},
    {"name": "statut", "type": "STRING", "length": 50, "nullable": false, "unique": false},
    {"name": "montantBudget", "type": "INTEGER", "length": 10, "nullable": true, "unique": false},
    {"name": "directionPersistenceId", "type": "LONG", "length": 255, "nullable": false, "unique": false}
  ],
  "relationships": [
    {"type": "many-to-one", "targetEntity": "Direction", "foreignKeyField": "directionPersistenceId"},
    {"type": "one-to-many", "targetEntity": "Document", "description": "Documents attached to FEB"}
  ]
}
```

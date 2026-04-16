# BDM Field Description Rules

## Mandatory Field Descriptions

**CRITICAL RULE:** All BDM fields MUST have a business-friendly description that a non-technical business owner can understand.

## Why This Rule Exists

1. **Business Documentation**: BDM serves as living documentation of business concepts
2. **Onboarding**: New team members can understand the data model without technical assistance
3. **Stakeholder Communication**: Business owners can review and validate data requirements
4. **Maintenance**: Developers can understand field purposes years after creation
5. **Compliance**: Clear documentation supports audit and regulatory requirements

## Description Requirements

### ✅ MANDATORY Elements

Every field description MUST:
1. **Explain the business purpose** - What this field represents in business terms
2. **Be in plain language** - Understandable by non-technical business owners
3. **Provide context** - When/how the field is used
4. **Include examples** when helpful - Sample values or formats
5. **Be in French** for this project - Match the business language

### ❌ What NOT to Do

Avoid technical jargon:
- ❌ "FK to parent entity"
- ❌ "Boolean flag for status check"
- ❌ "Persistence identifier"
- ❌ "Varchar field for user input"

Use business language instead:
- ✅ "Direction à l'origine de la demande"
- ✅ "Indicateur si la demande est active"
- ✅ "Identifiant unique de la demande"
- ✅ "Commentaires saisis par l'utilisateur"

## Description Format

### XML Structure

```xml
<field type="STRING" length="255" name="fieldName" nullable="false" collection="false">
    <description>Clear business description that explains the purpose and usage</description>
</field>
```

### Description Length

- **Minimum**: 20 characters (too short descriptions lack context)
- **Recommended**: 50-150 characters (clear but concise)
- **Maximum**: 500 characters (keep it readable)

## Description Patterns by Field Type

### 1. Identifiers and Codes

**Pattern:** "Unique identifier/code for [entity/purpose] (format: [example])"

```xml
<field type="STRING" length="50" name="numeroFEB" nullable="false" collection="false">
    <description>Numéro unique identifiant la Fiche d'Expression du Besoin (format: FEB-YYYY-NNNN)</description>
</field>

<field type="STRING" length="50" name="codeProfil" nullable="false" collection="false">
    <description>Code unique identifiant le profil utilisateur dans l'application (ex: INIT, VALID_RH)</description>
</field>
```

### 2. Dates and Timestamps

**Pattern:** "Date [when/what happens] [additional context]"

```xml
<field type="LOCALDATE" length="255" name="dateEmission" nullable="false" collection="false">
    <description>Date à laquelle la demande de recrutement a été créée par la direction</description>
</field>

<field type="LOCALDATETIME" length="255" name="dateCreation" nullable="false" collection="false">
    <description>Date et heure de création initiale de la fiche dans le système</description>
</field>
```

### 3. Status and State Fields

**Pattern:** "[What it represents] ([possible values])"

```xml
<field type="STRING" length="50" name="statut" nullable="false" collection="false">
    <description>État d'avancement de la demande dans le circuit de validation (Brouillon, En cours, Validé, Refusé)</description>
</field>

<field type="BOOLEAN" length="255" name="actif" nullable="false" collection="false">
    <description>Indicateur d'activation du compte : true pour compte actif, false pour compte désactivé</description>
</field>
```

### 4. Reference Fields (Foreign Keys)

**Pattern:** "[Referenced entity/concept] [additional context/purpose]"

```xml
<field type="STRING" length="255" name="directionEmettrice" nullable="false" collection="false">
    <description>Direction de la CNAF à l'origine de la demande de recrutement</description>
</field>

<field type="STRING" length="100" name="valideurUsername" nullable="true" collection="false">
    <description>Identifiant de l'utilisateur assigné pour effectuer la validation à cette étape</description>
</field>
```

### 5. Text and Comment Fields

**Pattern:** "[Type of content] [who provides it] [purpose]"

```xml
<field type="TEXT" length="255" name="commentaireInitiateur" nullable="true" collection="false">
    <description>Observations ou précisions apportées par le demandeur sur le contexte ou les besoins du poste</description>
</field>

<field type="TEXT" length="255" name="raisonRefus" nullable="true" collection="false">
    <description>Motif détaillé expliquant le refus de la demande par le valideur</description>
</field>
```

### 6. Descriptive Fields (Names, Titles)

**Pattern:** "[What it describes] [additional context] (ex: [examples])"

```xml
<field type="STRING" length="255" name="emploi" nullable="false" collection="false">
    <description>Intitulé du poste ou de l'emploi recherché (ex: Gestionnaire prestations, Conseiller allocataire)</description>
</field>

<field type="STRING" length="255" name="nomComplet" nullable="false" collection="false">
    <description>Nom et prénom complets de l'utilisateur pour l'affichage dans l'interface</description>
</field>
```

### 7. Technical Metadata Fields

**Pattern:** "[Technical aspect] [business purpose/usage]"

```xml
<field type="LONG" length="255" name="tailleFichier" nullable="false" collection="false">
    <description>Taille du fichier en octets pour contrôler les limites de téléchargement</description>
</field>

<field type="STRING" length="100" name="mimeType" nullable="false" collection="false">
    <description>Type MIME du fichier (application/pdf, image/jpeg) pour validation et affichage</description>
</field>
```

### 8. Numeric Fields (Counts, Quantities)

**Pattern:** "[What is counted/measured] [unit/context]"

```xml
<field type="INTEGER" length="10" name="ordreEtape" nullable="false" collection="false">
    <description>Numéro d'ordre de l'étape dans le processus de validation séquentiel (1, 2, 3, 4)</description>
</field>
```

## Quality Checklist

Before finalizing field descriptions, verify:

- ✅ Description is in French (for this project)
- ✅ No technical jargon (VARCHAR, FK, boolean, etc.)
- ✅ Business owner can understand without context
- ✅ Examples provided for coded values
- ✅ Format specified for identifiers
- ✅ Purpose is clear (why this field exists)
- ✅ Length is appropriate (50-150 chars recommended)
- ✅ Proper grammar and spelling
- ✅ Consistent terminology across fields
- ✅ All fields have descriptions (no exceptions)

## Examples - Before and After

### ❌ Poor Descriptions

```xml
<!-- Too technical -->
<field type="STRING" length="50" name="statut">
    <description>Status field</description>
</field>

<!-- Too vague -->
<field type="LOCALDATE" length="255" name="dateEmission">
    <description>Date field</description>
</field>

<!-- Missing context -->
<field type="BOOLEAN" length="255" name="actif">
    <description>Active</description>
</field>
```

### ✅ Good Descriptions

```xml
<!-- Clear business purpose with examples -->
<field type="STRING" length="50" name="statut" nullable="false" collection="false">
    <description>État d'avancement de la demande dans le circuit de validation (Brouillon, En cours, Validé, Refusé, Publié)</description>
</field>

<!-- Explains when and why -->
<field type="LOCALDATE" length="255" name="dateEmission" nullable="false" collection="false">
    <description>Date à laquelle la demande de recrutement a été créée par la direction</description>
</field>

<!-- Clear meaning with examples -->
<field type="BOOLEAN" length="255" name="actif" nullable="false" collection="false">
    <description>Indicateur d'activation du compte : true pour compte actif, false pour compte désactivé</description>
</field>
```

## Validation

Check all field descriptions:

```bash
# Count fields without descriptions
grep '<field type=' bdm/bom.xml | wc -l
grep -A1 '<field type=' bdm/bom.xml | grep '<description>' | wc -l

# Find fields without descriptions
grep -B1 '</field>' bdm/bom.xml | grep -v '<description>' | grep '<field'
```

## Integration with Generation Process

During BDM generation:

1. **Extract business context** from analysis document
2. **Map fields to business concepts** from requirements
3. **Write descriptions** in business language
4. **Include examples** for enumerated values
5. **Validate completeness** - all fields must have descriptions
6. **Review with business owner** before finalizing

## Summary

**MANDATORY:** Every field MUST have a clear, business-friendly description

**PURPOSE:** Enable business owners to understand and validate the data model

**LANGUAGE:** Use business terms, not technical jargon

**FORMAT:** 50-150 characters explaining purpose, context, and examples

**VALIDATION:** 100% of fields must have descriptions before generation completes

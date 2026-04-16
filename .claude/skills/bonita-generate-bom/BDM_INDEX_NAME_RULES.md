# BDM Index Name Rules

## Mandatory Index Name Length Limit

**CRITICAL RULE:** All index names MUST be 20 characters or less.

### Maximum Length: **20 characters**

This is a **MANDATORY** requirement for Bonita BDM indexes.

## Why This Rule Exists

- Database compatibility: Some databases have stricter identifier length limits
- Bonita internal processing: Index names may be used in generated code
- Best practices: Short, clear names improve readability and maintainability

## Naming Conventions

### ✅ GOOD Index Names (≤20 chars)

```xml
<!-- Short and descriptive (14 chars) -->
<index name="IDX_FEB_statut">
  <fieldNames><fieldName>statut</fieldName></fieldNames>
</index>

<!-- At the limit (20 chars) -->
<index name="IDX_FEB_dateEmission">
  <fieldNames><fieldName>dateEmission</fieldName></fieldNames>
</index>

<!-- Abbreviated entity name (16 chars) -->
<index name="IDX_valid_statut">
  <fieldNames><fieldName>statut</fieldName></fieldNames>
</index>

<!-- Using common abbreviations (14 chars) -->
<index name="IDX_user_actif">
  <fieldNames><fieldName>actif</fieldName></fieldNames>
</index>
```

### ❌ BAD Index Names (>20 chars)

```xml
<!-- TOO LONG - 26 chars -->
<index name="IDX_historique_utilisateur">
  <fieldNames><fieldName>utilisateurUsername</fieldName></fieldNames>
</index>

<!-- TOO LONG - 25 chars -->
<index name="IDX_utilisateur_direction">
  <fieldNames><fieldName>direction</fieldName></fieldNames>
</index>

<!-- TOO LONG - 24 chars -->
<index name="IDX_FEB_createurUsername">
  <fieldNames><fieldName>createurUsername</fieldName></fieldNames>
</index>
```

## Abbreviation Guidelines

When index names exceed 20 characters, use these abbreviation strategies:

### 1. Entity Name Abbreviations

| Full Name | Abbreviation | Example |
|-----------|-------------|---------|
| `validation` | `valid` | `IDX_valid_statut` (16 chars) |
| `historique` | `histo` | `IDX_histo_user` (14 chars) |
| `utilisateur` | `user` | `IDX_user_actif` (14 chars) |
| `document` | `doc` | `IDX_doc_type` (12 chars) |
| `FicheExpressionBesoin` | `FEB` | `IDX_FEB_statut` (14 chars) |

### 2. Field Name Abbreviations

| Full Name | Abbreviation | Example |
|-----------|-------------|---------|
| `createurUsername` | `createur` | `IDX_FEB_createur` (16 chars) |
| `valideurUsername` | `valideur` | `IDX_valid_valideur` (18 chars) |
| `dateEmission` | Keep full | `IDX_FEB_dateEmission` (20 chars) |

### 3. Multiple Field Abbreviations

For multi-field indexes, abbreviate both parts:

```xml
<!-- Multi-field index (20 chars max) -->
<index name="IDX_FEB_stat_date">
  <fieldNames>
    <fieldName>statut</fieldName>
    <fieldName>dateEmission</fieldName>
  </fieldNames>
</index>
```

## Index Naming Pattern

**Standard Pattern:** `IDX_{entity}_{field}`

- **IDX** = Index prefix (3 chars)
- **Underscore** = Separator (1 char)
- **Entity** = Abbreviated entity name (3-10 chars)
- **Underscore** = Separator (1 char)
- **Field** = Field name or abbreviation (remaining chars up to 20 total)

### Examples by Length

| Length | Index Name | Entity | Field |
|--------|-----------|--------|-------|
| 14 | `IDX_FEB_statut` | FEB | statut |
| 16 | `IDX_FEB_createur` | FEB | createur |
| 17 | `IDX_FEB_direction` | FEB | direction |
| 18 | `IDX_valid_valideur` | valid | valideur |
| 19 | `IDX_user_direction` | user | direction |
| 20 | `IDX_FEB_dateEmission` | FEB | dateEmission |

## Validation Checklist

Before generating BOM:

- ✅ All index names are 20 characters or less
- ✅ Names follow `IDX_{entity}_{field}` pattern
- ✅ Abbreviated entities are still recognizable
- ✅ No truncated or unclear abbreviations
- ✅ SQL-safe characters only (alphanumeric + underscore)

## Common Violations and Fixes

### 1. Entity Name Too Long

**Problem:** `IDX_ValidationEtape_statut` (25 chars)
**Fix:** `IDX_valid_statut` (16 chars)

### 2. Field Name Too Long

**Problem:** `IDX_FEB_createurUsername` (24 chars)
**Fix:** `IDX_FEB_createur` (16 chars)

### 3. Both Too Long

**Problem:** `IDX_historique_utilisateur` (26 chars)
**Fix:** `IDX_histo_user` (14 chars)

### 4. Multiple Fields

**Problem:** `IDX_FEB_statut_dateEmission` (28 chars)
**Fix:** `IDX_FEB_stat_date` (17 chars)

## Auto-Validation Script

Check all index names in BOM file:

```bash
grep '<index name=' bdm/bom.xml | sed 's/.*name="\([^"]*\)".*/\1/' | \
while read name; do
  len=${#name}
  if [ $len -gt 20 ]; then
    echo "❌ FAIL: $len chars - $name"
  else
    echo "✅ OK: $len chars - $name"
  fi
done
```

## Summary

**MANDATORY RULE:** Index names ≤ 20 characters

**Enforcement:** All index names MUST be validated before BOM generation

**Abbreviation Strategy:** Use entity and field abbreviations when needed

**Pattern:** `IDX_{entity}_{field}` with total length ≤ 20

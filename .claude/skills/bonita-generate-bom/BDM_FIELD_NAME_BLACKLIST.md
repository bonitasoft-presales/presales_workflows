# BDM Field Name Blacklist

## Restricted Field Names in Bonita BDM

These field names are **FORBIDDEN** in Bonita Business Data Model and must be avoided or renamed.

### Critical Reserved Names

| Restricted Name | Reason | Alternative Names |
|----------------|--------|-------------------|
| `description` | Reserved for `<description>` element at business object level | `descriptionTexte`, `detailDescription`, `commentaire`, `libelle` |
| `persistenceId` | Automatically added by Bonita (technical primary key) | `referenceId`, `identifiant`, `codeReference` |
| `persistenceVersion` | Automatically added by Bonita (optimistic locking) | `version`, `numeroVersion` |
| `class` | Java reserved keyword | `classe`, `categorie`, `type` |
| `type` | May conflict with BDM type system | `typeObjet`, `categorie`, `nature` |
| `new` | Java reserved keyword | `nouveau`, `estNouveau` |
| `return` | Java reserved keyword | `retour`, `resultat` |
| `extends` | Java reserved keyword | N/A |
| `implements` | Java reserved keyword | N/A |
| `package` | Java reserved keyword | `paquet`, `colis` |

### Recommended Naming Conventions

**DO:**
- Use descriptive, business-meaningful names: `commentaireUtilisateur`, `libelleAction`
- Use camelCase: `dateCreation`, `numeroFEB`
- Use French business terms when appropriate: `libelle`, `commentaire`, `texteDescription`

**DON'T:**
- Use generic names: `description`, `type`, `class`
- Use Java reserved keywords
- Use Bonita internal field names
- Use SQL reserved keywords in field names

### Conflict Resolution Examples

```xml
<!-- WRONG - Uses reserved "description" -->
<field type="TEXT" length="255" name="description" nullable="true" collection="false"/>

<!-- CORRECT - Uses specific alternative -->
<field type="TEXT" length="255" name="descriptionTexte" nullable="true" collection="false"/>
<field type="TEXT" length="255" name="commentaire" nullable="true" collection="false"/>
<field type="TEXT" length="255" name="detailsDescription" nullable="true" collection="false"/>
```

## Current BOM Conflicts

### Found Conflicts in `bdm/bom.xml`:

1. **RHHistoriqueAction** (line 125)
   - Field: `description`
   - Rename to: `descriptionAction`

2. **RHDocument** (line 168)
   - Field: `description`
   - Rename to: `descriptionDocument`

3. **RHProfil** (line 244)
   - Field: `description`
   - Rename to: `descriptionProfil`

## Validation Rule

**Before generating or updating BOM:**
- Check all field names against blacklist
- Rename any conflicts with context-specific alternatives
- Update queries that reference renamed fields
- Document renamed fields in BOM documentation

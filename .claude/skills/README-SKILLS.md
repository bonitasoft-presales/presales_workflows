# Bonita Skills - Modular Architecture

## Overview

The Bonita documentation and artifact generation process is organized into **modular, specialized skills** for better separation of concerns, reusability, and maintainability.

### Skill Categories

1. **Analysis Skill** - Document analysis and requirements extraction
2. **Generation Skills** - Individual artifact generators (BOM, Organization, Process, Profile)
3. **Validation Skill** - XSD schema validation
4. **Orchestrator Skill** - Coordinates all generation skills
5. **Deployment Skill** - Deploy artifacts to local Bonita server

## Available Skills

| Skill | Purpose | Input | Output |
|-------|---------|-------|--------|
| `/bonita-analyze-docs` | Analyze requirements and generate documentation | `docs/in/` | `docs/out/*.adoc` |
| `/bonita-generate` | **Orchestrator** - Generate all artifacts | Analysis .adoc | `docs/artifacts/` |
| `/bonita-generate-bom` | Generate Business Data Model | Analysis .adoc | `bom.xml` |
| `/bonita-generate-organization` | Generate Organization structure | Analysis .adoc | `organization.xml` |
| `/bonita-generate-process` | Generate Process diagram | Analysis .adoc | `*.proc` |
| `/bonita-generate-profile` | Generate Profiles | Analysis .adoc | `profile.xml` |
| `/bonita-validate-artifacts` | Validate all artifacts against XSD | `docs/artifacts/` | Validation report |
| `/bonita-deploy-local` | Deploy artifacts to local Bonita Studio | `app/target/` | Deployed application |

---

## Skill 1: bonita-analyze-docs (Analysis)

**Purpose:** Analyze requirements documents and generate comprehensive analysis documentation.

**Input:** Documents in `docs/in/` (PDFs, Word docs, text files, etc.)

**Output:** Analysis document (.adoc) in `docs/out/`

**Usage:**
```bash
/bonita-analyze-docs
```

**Steps:**
- Step 0: Cleanup (optional - remove old .adoc files)
- Steps 1-3: Document discovery, reading, and analysis
- Steps 4-5: Generate comprehensive AsciiDoc document

**Output File:** `docs/out/analyse-[project-name]-[date].adoc`

**Contents:**
- Project context and objectives
- Process workflow analysis
- Business rules and functional requirements
- **Data model (BOM entities with fields and relationships)**
- **Organization structure (users, roles, groups hierarchy)**
- **Process actors, tasks, and workflow**
- **Connector recommendations with code examples**
- **UI Builder specifications**
- **Profiles and access control**

---

## Skill 2: bonita-generate (Orchestrator)

**Purpose:** **Orchestrate** all artifact generation by calling specialized sub-skills.

**Input:** Analysis document (.adoc) from `docs/out/`

**Output:** Complete set of Bonita artifacts in `docs/artifacts/`

**Usage:**
```bash
# Generate all artifacts
/bonita-generate

# Generate from specific analysis document
/bonita-generate --input docs/out/analyse-project.adoc

# Skip README or validation
/bonita-generate --skip-readme --skip-validation
```

**Orchestration Flow:**
1. Step 0: Prepare (create directory, select analysis document)
2. Step 1: Call `/bonita-generate-bom`
3. Step 2: Call `/bonita-generate-organization`
4. Step 3: Call `/bonita-generate-process`
5. Step 4: Call `/bonita-generate-profile`
6. Step 5: Generate README-ARTIFACTS.md
7. Step 6: Call `/bonita-validate-artifacts`
8. Step 7: Provide comprehensive summary

**Output Files:**
```
docs/artifacts/
├── bom.xml                  # Business Object Model
├── organization.xml         # Users, roles, groups
├── ProcessName-1.0.proc    # BPMN process diagram
├── profile.xml              # Application profiles
└── README-ARTIFACTS.md     # Complete documentation
```

---

## Skills 3-6: Individual Artifact Generators

These specialized skills can be used **independently** or via the orchestrator:

### 3. bonita-generate-bom

Generate Business Data Model (BDM) from analysis document.

**Usage:**
```bash
/bonita-generate-bom --input docs/out/analyse-project.adoc
```

**Features:**
- Extracts BDM entities with fields and relationships
- Generates Bonita 10.x compatible BOM XML
- Uses LONG foreign keys (no AGGREGATION/COMPOSITION)
- Avoids duplicate query names
- Validates against `.claude/xsd/bom.xsd`

**Output:** `docs/artifacts/bom.xml`

---

### 4. bonita-generate-organization

Generate Organization structure (users, roles, groups) from analysis document.

**Usage:**
```bash
/bonita-generate-organization --input docs/out/analyse-project.adoc
```

**Features:**
- Extracts organizational structure (roles, groups, users)
- Creates test users with password "bpm"
- Supports hierarchical groups (parent-child relationships)
- Generates memberships (user-role-group assignments)
- Validates against `.claude/xsd/organization.xsd`

**Output:** `docs/artifacts/organization.xml`

---

### 5. bonita-generate-process

Generate BPMN Process Diagram from analysis document.

**Usage:**
```bash
/bonita-generate-process --input docs/out/analyse-project.adoc
```

**Features:**
- Extracts workflow structure (tasks, gateways, events, flows)
- Generates UUIDs using Docker Python
- Creates Bonita 10.x compatible .proc file (bonitaModelVersion="9")
- Maps actors to organization roles
- Includes visual notation for Bonita Studio
- Validates against `.claude/xsd/ProcessDefinition.xsd`

**Output:** `docs/artifacts/ProcessName-1.0.proc`

---

### 6. bonita-generate-profile

Generate Application Profiles from analysis document.

**Usage:**
```bash
/bonita-generate-profile --input docs/out/analyse-project.adoc
```

**Features:**
- Extracts profile definitions and mappings
- Includes standard Bonita profiles (User, Administrator)
- Supports custom application profiles
- Maps profiles to roles, groups, users, memberships
- Validates against `.claude/xsd/profiles.xsd`

**Output:** `docs/artifacts/profile.xml`

---

## Skill 7: bonita-deploy-local (Deployment)

Deploy generated artifacts to local Bonita Studio server.

**Purpose:** Automate the build and deployment process to a local Bonita server.

**Usage:**
```bash
# Build and deploy with defaults
/bonita-deploy-local

# Deploy without building (use existing artifacts)
/bonita-deploy-local --skip-build

# Deploy to custom URL
/bonita-deploy-local --url http://localhost:8080/bonita --username install --password install
```

**Features:**
- Builds project using `infrastructure/build.sh` script
- Locates artifact matching pattern: `app/target/<PROJECT_NAME>-<PROJECT_VERSION>-presales.zip`
- Downloads bonita-la-deployer (v1.0.0) if not present
- Deploys to local Bonita server using REST API
- Development mode enabled (replaces existing artifacts)

**Output:** Application deployed and accessible at Bonita Portal

**Prerequisites:**
- Docker installed and running
- Bonita Studio/Runtime running at target URL (default: http://localhost:8080/bonita)
- Valid credentials (default: install/install)
- Access to bonitasoft.jfrog.io Docker registry

---

## Skill 8: bonita-validate-artifacts (Validation)

Validate all Bonita artifacts against XSD schemas.

**Purpose:** Comprehensive validation of all generated or manually edited artifacts.

**Usage:**
```bash
# Validate all artifacts in default directory
/bonita-validate-artifacts

# Validate in specific directory
/bonita-validate-artifacts --directory docs/artifacts/

# Validate single file
/bonita-validate-artifacts --file docs/artifacts/bom.xml
```

**Features:**
- Validates BOM against `bom.xsd`
- Validates Organization against `organization.xsd`
- Validates Process diagrams against `ProcessDefinition.xsd`
- Validates Profiles against `profiles.xsd`
- Generates comprehensive validation report
- Provides detailed error messages and fixes
- Exit code 0 (success) or 1 (failure)

**Example Output:**
```
Bonita Artifacts Validation Report
===================================

✓ bom.xml (12,345 bytes, 234 lines)
✓ organization.xml (8,912 bytes, 176 lines)
✓ ProcessName-1.0.proc (15,678 bytes, 456 lines)
✓ profile.xml (3,456 bytes, 89 lines)

Total: 4 files validated
Success: 4 ✓
Status: All artifacts valid
```

---

## Typical Workflows

### Workflow 1: Complete Generation and Deployment (Recommended)

Generate all artifacts and deploy to local server:

```bash
# 1. Analyze documents
/bonita-analyze-docs

# 2. Review analysis document (optional)
cat docs/out/analyse-project-2026-01-27.adoc

# 3. Generate all artifacts
/bonita-generate

# 4. Copy artifacts to app structure (if needed)
cp docs/artifacts/*.proc app/diagrams/
cp docs/artifacts/bom.xml app/bdm/
cp docs/artifacts/organization.xml app/organizations/

# 5. Build and deploy
/bonita-deploy-local
```

### Workflow 2: Selective Regeneration

Regenerate only specific artifacts:

```bash
# Regenerate only BOM after updating data model
/bonita-generate-bom --input docs/out/analyse-project.adoc

# Regenerate only Organization after changing users/roles
/bonita-generate-organization --input docs/out/analyse-project.adoc

# Validate after regeneration
/bonita-validate-artifacts
```

### Workflow 3: Manual Editing + Validation

Edit artifacts manually and validate:

```bash
# Edit BOM manually
vim docs/artifacts/bom.xml

# Validate to ensure correctness
/bonita-validate-artifacts --file docs/artifacts/bom.xml
```

### Workflow 4: Iterative Development

Iterate on analysis, generation, and deployment:

```bash
# 1. Initial analysis
/bonita-analyze-docs

# 2. Generate artifacts
/bonita-generate

# 3. Copy to app structure and deploy
cp docs/artifacts/*.proc app/diagrams/
/bonita-deploy-local

# 4. Test in Bonita Portal, identify issues

# 5. Edit analysis document to refine requirements
vim docs/out/analyse-project-2026-01-27.adoc

# 6. Regenerate specific artifact
/bonita-generate-process --input docs/out/analyse-project-2026-01-27.adoc

# 7. Copy and redeploy
cp docs/artifacts/*.proc app/diagrams/
/bonita-deploy-local --skip-build  # Faster: skip Maven build

# 8. Test again and iterate
```

### Workflow 5: Quick Deployment

Rapid deployment during development:

```bash
# Make changes to code/diagrams in app/

# Build and deploy
/bonita-deploy-local

# Or even faster with existing build:
/bonita-deploy-local --skip-build
```

---

## Architecture Benefits

### 1. Modularity
- Each artifact type has dedicated, focused skill
- Generate individual artifacts without full regeneration
- Example: Update BOM without touching Organization or Process

### 2. Reusability
- Sub-skills usable outside orchestrator
- Validation skill useful for manual editing workflows
- Mix and match skills for custom workflows

### 3. Testability
- Each skill tested in isolation
- Clear separation of concerns
- Easier to debug individual artifact generation

### 4. Maintainability
- Changes isolated to specific skills
- Orchestrator remains simple and stable
- Clear documentation per artifact type

### 5. Flexibility
- Use orchestrator for complete workflow
- Use individual skills for granular control
- Extend with new artifact types easily

### 6. Validation
- Mandatory XSD validation in all generation skills
- Separate validation skill for ad-hoc checks
- Ensures Bonita Studio compatibility

---

## Directory Structure

```
.claude/skills/
├── bonita-analyze-docs/              # Analysis skill
│   ├── SKILL.md
│   └── steps/
│
├── bonita-generate/                  # Orchestrator skill
│   ├── SKILL.md
│   └── steps/
│
├── bonita-generate-bom/              # BOM generator
│   ├── SKILL.md
│   └── steps/
│       ├── 01-extract-entities.md
│       ├── 02-generate-xml.md
│       └── 03-validate-xsd.md
│
├── bonita-generate-organization/     # Organization generator
│   ├── SKILL.md
│   └── steps/
│       ├── 01-extract-org.md
│       ├── 02-generate-xml.md
│       └── 03-validate-xsd.md
│
├── bonita-generate-process/          # Process generator
│   ├── SKILL.md
│   └── steps/
│       ├── 01-extract-workflow.md
│       ├── 02-generate-uuids.md
│       ├── 03-generate-proc.md
│       └── 04-validate-xsd.md
│
├── bonita-generate-profile/          # Profile generator
│   ├── SKILL.md
│   └── steps/
│       ├── 01-extract-profiles.md
│       ├── 02-generate-xml.md
│       └── 03-validate-xsd.md
│
└── bonita-validate-artifacts/        # Validation utility
    ├── SKILL.md
    └── steps/
        ├── 01-validate-bom.md
        ├── 02-validate-organization.md
        ├── 03-validate-process.md
        ├── 04-validate-profile.md
        └── 05-generate-report.md

docs/
├── in/                               # Input documents
├── out/                              # Analysis documents (.adoc)
└── artifacts/                        # Generated Bonita artifacts

.claude/xsd/                          # XSD schemas
├── bom.xsd
├── organization.xsd
├── ProcessDefinition.xsd
└── profiles.xsd
```

---

## XSD Validation

All generation skills include mandatory XSD validation:

| Artifact | XSD Schema | Validation Tool |
|----------|------------|-----------------|
| `bom.xml` | `.claude/xsd/bom.xsd` | Docker xmllint |
| `organization.xml` | `.claude/xsd/organization.xsd` | Docker xmllint |
| `*.proc` | `.claude/xsd/ProcessDefinition.xsd` | Docker xmllint |
| `profile.xml` | `.claude/xsd/profiles.xsd` | Docker xmllint |

**Validation Command Pattern:**
```bash
docker run --rm \
  -v "$(pwd)/.claude/xsd":/xsd:ro \
  -v "$(pwd)/docs/artifacts":/artifacts:ro \
  cytopia/xmllint \
  xmllint --schema /xsd/bom.xsd /artifacts/bom.xml --noout
```

---

## Bonita 10.x Compatibility

All skills ensure Bonita 10.x compatibility:

- **BOM:** Uses LONG foreign keys (NO AGGREGATION/COMPOSITION)
- **Process:** Uses `bonitaModelVersion="9"`
- **Organization:** Uses schema version 1.1
- **Profiles:** Uses schema version 1.0
- **Validation:** All XML validated before saving

---

## Import into Bonita Studio

After generating artifacts:

1. **Import BDM:**
   - Development → Business Data Model → Import → Select `bom.xml`

2. **Import Organization:**
   - Organization → Manage → Import → Select `organization.xml`

3. **Import Process:**
   - File → Import → BPM Diagram → Select `*.proc` file

4. **Import Profiles:**
   - Organization → Profiles → Import → Select `profile.xml`

---

## Troubleshooting

### Skill Not Found
**Error:** `/bonita-generate-bom: command not found`

**Solution:**
- Ensure all skills are in `.claude/skills/` directory
- Skills are automatically discovered by Claude Code
- Restart Claude Code if needed

### Validation Fails
**Error:** XML validation fails with XSD errors

**Solution:**
1. Check XSD schemas exist in `.claude/xsd/`
2. Review validation error message (line number, element)
3. Common fixes:
   - Wrong namespace → Check `xmlns` attribute
   - Invalid field type → Use valid Bonita types only
   - Missing required element → Add missing sections
4. Use `/bonita-validate-artifacts` for detailed errors

### Docker Not Available
**Error:** Cannot run Docker commands

**Solution:**
- Install Docker Desktop
- Ensure Docker daemon is running
- Check Docker availability: `docker --version`

### Analysis Document Incomplete
**Error:** Generated artifact missing data

**Solution:**
1. Review analysis document in `docs/out/`
2. Check that all sections are present (BOM, Organization, Process, Profiles)
3. Re-run `/bonita-analyze-docs` if needed
4. Manually edit analysis document to add missing information
5. Regenerate specific artifact

---

## Advanced Usage

### Custom Package Names

Modify BOM package name in analysis document:
```asciidoc
=== Data Model Package
com.mycompany.myproject.model
```

### Multiple Processes

Generate multiple processes from one analysis:
```bash
# Extract different process sections to separate .adoc files
/bonita-generate-process --input docs/out/process1.adoc
/bonita-generate-process --input docs/out/process2.adoc
```

### CI/CD Integration

Use validation in build pipelines:
```bash
#!/bin/bash
/bonita-generate
if [ $? -eq 0 ]; then
  echo "Generation successful"
  /bonita-validate-artifacts
  exit $?
else
  echo "Generation failed"
  exit 1
fi
```

---

## Performance Tips

- **Parallel Generation:** Individual skills can run in parallel if needed
- **Caching:** Analysis document can be reused for multiple generations
- **Selective Regeneration:** Only regenerate changed artifacts
- **Validation:** Run validation only when needed (use `--skip-validation`)

---

## Support and Documentation

- **Skill Documentation:** Each skill has detailed `SKILL.md` in its directory
- **Step Documentation:** Each step has detailed `.md` file with examples
- **Bonita Documentation:** https://documentation.bonitasoft.com/
- **Bonita Community:** https://community.bonitasoft.com/

---

**Version:** 3.1 (Modular Architecture with Deployment)
**Last Updated:** 2026-01-27
**Architecture:** Modular skills with orchestration and deployment
**Skills:** 8 total (1 analysis + 1 orchestrator + 4 generators + 1 validator + 1 deployer)

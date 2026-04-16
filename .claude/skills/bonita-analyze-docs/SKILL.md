---
name: bonita-analyze-docs
description: Analyze requirements documents and generate comprehensive analysis documentation. Use when the user wants to analyze, parse, or process requirements from docs/in/ to generate an AsciiDoc analysis file.
context: fork
argument-hint: "[--input <doc-path>]"
allowed-tools: Read, Bash, Glob, Grep
---

Analyze all documents in the `docs/in/` directory and generate a comprehensive analysis document (.adoc) with all information needed to create Bonita BPM processes and applications.

This skill focuses on **analysis and documentation only**. To generate Bonita artifacts (XML and .proc files), use the `/bonita-generate` skill after completing the analysis.

## Global Directives

**IMPORTANT GLOBAL DIRECTIVE**: If you need any tooling (python3, xmllint, jq, etc.), use a Docker version to run the tool instead of relying on local installation. Example: `docker run --rm python:3 python3 -c "import uuid; print(uuid.uuid4())"` or `docker run --rm alpine:latest sh -c "apk add --no-cache libxml2-utils >/dev/null 2&1 && xmllint xmllint --version`.

## Execution Steps

Follow these steps in order:

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--input`) before starting.

### Step 0: Cleanup Previously Generated Analysis
[Read detailed instructions](steps/00-cleanup-artifacts.md)
- Ask user if they want to clean up old analysis files from `docs/out/`
- If yes: Remove all *.adoc files from `docs/out/`
- If no: Keep existing files (new analysis will have timestamped filename)

### Steps 1-3: Document Analysis
[Read detailed instructions](steps/01-03-document-analysis.md)
- Step 1: Discover Documents in `docs/in/`
- Step 2: Read and Analyze Each Document (PDFs, Word, text files, etc.)
- Step 3: Cross-Reference and Validate

### Steps 4-5: AsciiDoc Generation
[Read detailed instructions](steps/04-05-asciidoc-generation.md)
- Step 4: Structure Output (organize all extracted information)
- Step 5: Generate Comprehensive AsciiDoc File

The AsciiDoc file should include:
- Project context and objectives
- Process workflow analysis (AS-IS and TO-BE)
- Business rules
- Functional requirements (mandatory and optional)
- Technical constraints
- **Data model (BOM entities with fields and relationships)**
- **Organization structure (users, roles, groups hierarchy)**
- **Process actors and tasks**
- **Connector recommendations with code examples**
- **UI Builder specifications with menu structures and page layouts**
- **Profiles and access control**
- Risk analysis and planning

## Final Output

The skill generates **1 comprehensive file** in the `docs/out/` directory:

**`analyse-[project-name]-[date].adoc`** - Complete analysis document containing:
- All requirements extracted from source documents
- BDM entity descriptions (ready for artifact generation)
- Organization structure (users, roles, groups)
- Process workflow and tasks
- Connector recommendations
- UI specifications
- Implementation guidance

## Next Steps

After completing the analysis:

1. **Review the analysis document** to ensure completeness
2. **Run `/bonita-generate`** to create Bonita artifacts (BOM, Organization, Process, Profiles)
3. The generated artifacts will be placed in `docs/artifacts/` ready for import into Bonita Studio

## Notes

- This skill does **not** generate XML or .proc files (use `/bonita-generate` for that)
- The analysis document serves as the single source of truth for artifact generation
- If documents contain diagrams or flowcharts, pay special attention to extracting the process flow, decision points, and task sequences
- If requirements are ambiguous or incomplete, clearly state what additional information is needed
- The analysis document is designed to be comprehensive enough that artifacts can be generated from it alone

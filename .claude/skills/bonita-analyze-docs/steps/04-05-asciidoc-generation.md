# Steps 4-5: AsciiDoc Generation

## Step 4: Structure Output

* Organize extracted information in AsciiDoc format (.adoc)
* **CRITICAL**: Output must be saved as a file in `docs/out/` directory
* File name should reflect project/analysis date (e.g., `analysis-YYYY-MM-DD.adoc` or `requirements-analysis.adoc`)
* Structure the document with these main sections:

### 1. Business Case
- Executive summary of the business need
- Problem statement
- Objectives and goals
- Expected benefits
- Success criteria
- Stakeholders

### 2. Data Model (BDM)
- List all business entities identified
- For each entity:
  * Entity name
  * Description
  * Attributes with types (String, Integer, Date, Boolean, etc.)
  * Relationships with other entities
  * Constraints and validations
- Provide a visual representation if possible (table or list format)
- Suggest BDM package structure

### 3. Process(es)
- For each process identified:
  * Process name and description
  * Process flow (step-by-step)
  * Tasks (User tasks, Service tasks, Script tasks)
  * Decision points (gateways)
  * Events (start, end, timers, messages)
  * Pools and lanes if multiple actors
  * Process variables needed
  * Connectors or integrations required
- Include process diagrams description from flowcharts

### 4. Actors
- List all actors/roles identified
- For each actor:
  * Actor name
  * Description/responsibilities
  * Which tasks they perform
  * Required permissions
- Organization structure (groups, roles hierarchy)
- User profiles

## Step 5: Generate AsciiDoc File

* Use proper AsciiDoc syntax:
  - `= Title` for document title (level 0)
  - `== Section` for main sections (level 1)
  - `=== Subsection` for subsections (level 2)
  - Tables using AsciiDoc table syntax
  - Lists using `*` or `.` for items
  - Code blocks using `----` delimiters
  - Bold/italic using `*bold*` and `_italic_`
* Ensure `docs/out/` directory exists (create if needed)
* Write the complete analysis to the .adoc file
* Confirm file creation and provide path

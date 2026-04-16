# Steps 1-3: Document Analysis

## Step 1: Discover Documents

* List all files in `docs/in/` directory
* Identify document types (PDF, Word, Excel, text files, images, etc.)
* Report what documents are available for analysis

## Step 2: Read and Analyze Each Document

* Use the Read tool to examine each document (supports PDF, images, etc.)
* Extract the following information relevant to Bonita application development:

### Process Information
- Process names and descriptions
- Process flows and step sequences
- Decision points and conditional flows
- Parallel or sequential execution patterns
- Loop conditions
- Process events (start events, end events, intermediate events, timers)
- Sub-processes or call activities

### Task Information
- User tasks (human activities)
- Service tasks (automated activities)
- Script tasks
- Task names and descriptions
- Expected duration or SLAs
- Task priorities

### Actor and Organization
- Actors (who performs which tasks)
- Roles and groups
- Organization structure
- User profiles and permissions
- Initiator requirements

### Data and Business Objects
- Business data model entities (BDM objects)
- Entity attributes and types
- Relationships between entities (one-to-many, many-to-many)
- Process variables
- Business data queries needed

### Forms and UI Requirements
- Form fields and their types
- Input validation rules
- UI layouts and structure
- Required widgets (date picker, file upload, tables, etc.)
- Form submission actions

### Business Rules
- Decision logic and conditions
- Calculation formulas
- Validation rules
- Business constraints

### Integration Requirements
- External systems to integrate
- APIs to call (REST, SOAP)
- Database connections
- Email notifications
- File operations

### Application Structure
- Application pages needed
- Navigation and menu structure
- Custom layouts or themes
- Reports or dashboards

### Technical Constraints
- Performance requirements
- Security requirements
- Specific technologies mentioned
- Compliance requirements

## Step 3: Cross-Reference and Validate

* Compare information across multiple documents
* Identify contradictions or gaps
* Highlight unclear requirements that need clarification
* Create a unified view of requirements

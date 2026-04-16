---
name: bonita-generate-process
description: Generate Bonita Process Diagram (.proc) from analysis document. Use when the user wants to generate, create, or build a BPMN process diagram or .proc file.
argument-hint: "[--input <analysis-file>] [--output <path>]"
allowed-tools: Read, Write, Bash, Glob, Grep
---

Generate a Bonita Process Diagram (.proc) XML file from an analysis document. The generated file conforms to Bonita 10.x XMI format with bonitaModelVersion="9" (model version, not runtime version) and saves to `app/diagrams/` with automatic version collision detection.

## Usage

```bash
# Generate process diagram from default analysis document
/bonita-generate-process

# Generate process diagram from specific analysis document
/bonita-generate-process --input docs/out/analyse-project-2026-01-23.adoc

# Generate process diagram to custom output path
/bonita-generate-process --input docs/out/analyse-project-2026-01-23.adoc --output custom/path/ProcessName-1.0.proc
```

## Parameters

- `--input <path>` - Path to analysis document (default: most recent .adoc in `docs/out/`)
- `--output <path>` - Output path for .proc file (default: `app/diagrams/ProcessName-1.0.proc`)

## CRITICAL: Output Location and Version Management

**MANDATORY RULE:** All process diagrams MUST be saved in `app/diagrams/` directory.

**Version Collision Prevention:**
1. Before generating, check if `app/diagrams/ProcessName-X.Y.proc` already exists
2. If file exists, increment the version number (X.Y → X.Y+1)
3. Continue incrementing until finding an available version number
4. Use the next available version in the generated file

**Example:**
- If `ValidationRecrutement-1.0.proc` exists
- Check for `ValidationRecrutement-1.1.proc`
- If that exists too, check `ValidationRecrutement-1.2.proc`
- Use the first available version number

**Version Format:** `ProcessName-MAJOR.MINOR.proc`
- MAJOR: Increment for breaking changes
- MINOR: Increment for new file creation to avoid collision
- Default starting version: `1.0`

## Prerequisites

- Analysis document containing process workflow section with tasks, actors, and flow
- Docker for UUID generation and XML validation
- Process samples in `.claude/process-samples/` for structure reference

## Process Samples

**IMPORTANT**: Reference real process samples in `.claude/process-samples/` for accurate structure:

Available samples (production-grade Bonita 10.x processes):
- `NewVacationRequest-7.11.proc` (353KB) - Complex process with contracts, gateways, business data
- `CancelVacationRequest-7.11.proc` (94KB) - XOR gateways with default transitions
- `Onboarding-7.15.proc` (467KB) - Multi-lane process with parallel gateways
- `InitiateVacationAvailable-7.11.proc` (18KB) - Simple process with business data initialization
- Setup processes (`_Setup*.proc`) - Data initialization patterns

**Use these samples to:**
1. Understand correct XML structure and element nesting
2. See proper contract definitions with inputs and operations
3. Learn XOR gateway patterns with default transitions
4. Study business data integration and operations
5. Reference proper namespace usage and element types

**Key patterns from samples:**
- XOR gateways always have one `isDefault="true"` outgoing flow
- Pool and tasks have contracts with business data mappings
- Contract inputs map to business data through operation elements
- Multiple configuration environments (presales, Qualification, etc.)

## Global Directives

**IMPORTANT**: Use Docker for all tooling:
- XML validation: `docker run --rm alpine:latest sh -c "apk add --no-cache libxml2-utils >/dev/null 2&1 && xmllint ...`
- Python scripts: `docker run --rm python:3-alpine python3 -c "..."`
- UUID generation: `docker run --rm python:3-alpine python3 -c "import uuid; [print(str(uuid.uuid4())) for _ in range(50)]"`

## Execution Steps

> **Arguments**: Apply user-provided options from `$ARGUMENTS` (e.g., `--input`, `--output`) before starting.

### Step 1: Extract Workflow from Analysis
[Read detailed instructions](steps/01-extract-workflow.md)
- Read analysis document (AsciiDoc format)
- Find process workflow section
- Extract process name and version
- Identify actors and their roles
- Extract tasks (user tasks, service tasks)
- Extract decision points (gateways)
- Identify sequence flow and conditions
- Map actors to organization roles

### Step 2: Generate UUIDs
[Read detailed instructions](steps/02-generate-uuids.md)
- Count all elements needing IDs (pool, lanes, events, tasks, gateways, transitions, actors, etc.)
- Generate sufficient UUIDs using Docker Python
- Store UUIDs for use in XML generation
- Format: lowercase with hyphens (e.g., "a1b2c3d4-e5f6-7890-abcd-ef1234567890")

### Step 3: Generate Process Diagram XML
[Read detailed instructions](steps/03-generate-proc.md)
- **Check for existing file in app/diagrams/** and increment version if needed
- Extract process name and determine version (avoid collisions)
- Create XMI root with proper namespaces
- Generate MainProcess with bonitaModelVersion="9" and version attribute
- Create Pool with process name and version
- **Define Pool Contract** with instantiation inputs (if BDM integration required)
- **Declare Business Data** on Pool with initialization script in defaultValue (if BDM exists)
- Add Lanes for each actor
- Add StartEvent and EndEvent(s)
- Add Tasks (userTask, automaticTask)
  - **Add Task Contracts** with inputs for human tasks
  - **Add Task Operations** to update BDM from contract inputs
- Add Gateways (EXCLUSIVE for XOR decisions)
  - **Add Gateway Conditions** referencing BDM fields set by previous tasks
- Create SequenceFlow connections
- Define Actors with initiator flag
- Add presales Configuration with actor mappings
- **Add DataTypes** declarations (BooleanType, DateType, IntegerType, StringType, BusinessObjectType)
- Include notation:Diagram for visual layout with label decorations
- Save to app/diagrams/ProcessName-X.Y.proc

### Step 4: Validate XML Well-Formedness
[Read detailed instructions](steps/04-validate-xsd.md)
- Validate XML well-formedness using xmllint
- Compare structure with working sample files
- Verify XMI format compliance
- Check all elements have unique IDs
- Report validation results

## Output

The skill generates **1 file**:

**`app/diagrams/ProcessName-X.Y.proc`** - Bonita Process Diagram containing:
- XMI structure with proper namespaces
- MainProcess definition with version attribute and bonitaModelVersion="9"
- Pool with process name, version, and instantiation contract
- Business data declaration (if BDM exists) with initialization script
- Lanes for actor organization
- BPMN elements (events, tasks, gateways)
  - Tasks with contracts and operations (if BDM integration)
  - Gateways with BDM-based conditions
- SequenceFlow connections
- Actor definitions with role mappings
- Configuration for presales environment with actor-to-role mappings
- DataTypes declarations (BooleanType, DateType, IntegerType, StringType, BusinessObjectType)
- Visual notation for diagram layout with label decorations

## Critical Requirements for Bonita 10.x

### 1. Use bonitaModelVersion="9" and Version Attribute

All .proc files for Bonita 10.x must use:
```xml
<process:MainProcess xmi:id="uuid" name="ProcessName" version="X.Y" bonitaModelVersion="9">
```

**CRITICAL**: The `version` attribute is MANDATORY on MainProcess. Without it, Bonita Studio defaults to version "1.0". The MainProcess version MUST match the Pool version and filename version.

### 2. Proper XMI Namespaces

Root element must declare all required namespaces:
```xml
<xmi:XMI xmi:version="2.0"
  xmlns:xmi="http://www.omg.org/XMI"
  xmlns:actormapping="http://www.bonitasoft.org/ns/actormapping/6.0"
  xmlns:configuration="http://www.bonitasoft.org/ns/bpm/configuration"
  xmlns:decision="http://www.bonitasoft.org/ns/bpm/process/decision"
  xmlns:expression="http://www.bonitasoft.org/ns/bpm/expression"
  xmlns:notation="http://www.eclipse.org/gmf/runtime/1.0.3/notation"
  xmlns:parameter="http://www.bonitasoft.org/ns/bpm/parameter"
  xmlns:process="http://www.bonitasoft.org/ns/bpm/process">
```

### 3. Unique XMI IDs

All elements must have unique `xmi:id` attributes:
- Use UUID format: lowercase with hyphens
- Generate using: `docker run --rm python:3-alpine python3 -c "import uuid; print(uuid.uuid4())"`
- Never reuse IDs across different elements

### 4. IDREF for Connections

Use IDREF attributes for connections:
- `source` and `target` in SequenceFlow
- `incoming` and `outgoing` in flow nodes
- `actor` attribute in Lane
- Must reference valid xmi:id values

### 5. Gateway Types and Default Transitions

Use correct gateway types:
- `process:XORGateway` - Exclusive, only one path taken (most common for decision points)
- `process:ANDGateway` - Parallel, all paths taken simultaneously
- `process:InclusiveGateway` - Inclusive, one or more paths taken based on conditions

**CRITICAL RULES for XOR Gateways:**
1. Every XORGateway MUST have exactly one outgoing SequenceFlow with `isDefault="true"`. This ensures the process doesn't deadlock if no conditional transitions evaluate to true.
2. Default flows (isDefault="true") MUST NOT have a name attribute - this avoids label clutter in diagrams.
3. Gateway conditions MUST reference BDM entity fields set in previous tasks, NOT local contract input variables.
4. All conditions MUST use interpreter="GROOVY" and returnType="java.lang.Boolean".

**Example with BDM Field References:**
```xml
<!-- XOR Gateway with 2 conditional flows + 1 default flow -->
<!-- Gateway evaluates decision field from BDM entity set in previous task -->
<connections xmi:type="process:SequenceFlow" xmi:id="uuid1"
             name="Oui" source="gateway_uuid" target="task1_uuid">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="uuid"/>
  <condition xmi:type="expression:Expression" xmi:id="uuid" name=""
             content="ficheExpressionBesoin.decisionRH == true"
             interpreter="GROOVY" returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>
<connections xmi:type="process:SequenceFlow" xmi:id="uuid2"
             name="Non" source="gateway_uuid" target="task2_uuid">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="uuid"/>
  <condition xmi:type="expression:Expression" xmi:id="uuid" name=""
             content="ficheExpressionBesoin.decisionRH == false"
             interpreter="GROOVY" returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>
<!-- Default flow - taken if no conditions match (NO name attribute) -->
<connections xmi:type="process:SequenceFlow" xmi:id="uuid3"
             source="gateway_uuid" target="end_uuid" isDefault="true">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="uuid"/>
  <condition xmi:type="expression:Expression" xmi:id="uuid" name=""
             content="" returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>
```

**Key Points:**
- ❌ WRONG: `content="decision == true"` (references local variable)
- ✅ CORRECT: `content="ficheExpressionBesoin.decisionRH == true"` (references BDM field)
- Gateway conditions evaluate fields that were SET by operations in previous human tasks
- BDM entity name matches the process data variable name

### 6. Actor Configuration

**CRITICAL**: Actor mappings MUST use organization ROLES, NOT group names.

Always include presales configuration with correct role mappings:
```xml
<configurations xmi:type="configuration:Configuration" name="presales" version="9" username="walter.bates">
  <actorMappings>
    <actorMapping name="ActorName">
      <groups xmi:type="actormapping:Groups" xmi:id="uuid"/>
      <memberships xmi:type="actormapping:Membership" xmi:id="uuid"/>
      <roles xmi:type="actormapping:Roles" xmi:id="uuid">
        <role>organization_role_name</role>
      </roles>
      <users xmi:type="actormapping:Users" xmi:id="uuid"/>
    </actorMapping>
  </actorMappings>
</configurations>
```

**IMPORTANT**:
- Read the organization file (typically `app/organizations/*.xml`) to identify correct role names
- Use role names from `<roles><role name="...">` elements, NOT group names from `<groups><group name="...">`
- Example: Use `valideur_rh` (role), NOT `rh` (group)
- Multiple roles can be assigned to a single actor if needed (e.g., `valideur_rh` + `valideur_final_rh`)

### 7. Required Expression Elements

All flow nodes must have these expression elements (even if empty):
```xml
<dynamicLabel xmi:type="expression:Expression" xmi:id="uuid" name="" content="" returnTypeFixed="true"/>
<dynamicDescription xmi:type="expression:Expression" xmi:id="uuid" name="" content="" returnTypeFixed="true"/>
<stepSummary xmi:type="expression:Expression" xmi:id="uuid" name="" content="" returnTypeFixed="true"/>
```

### 8. Form Mappings

**Pool-level form mappings:**
```xml
<formMapping xmi:type="process:FormMapping" xmi:id="uuid" type="NONE">
  <targetForm xmi:type="expression:Expression" xmi:id="uuid" name="" content="" type="FORM_REFERENCE_TYPE" returnTypeFixed="true"/>
</formMapping>
<overviewFormMapping xmi:type="process:FormMapping" xmi:id="uuid">
  <targetForm xmi:type="expression:Expression" xmi:id="uuid" name="" content="" type="FORM_REFERENCE_TYPE" returnTypeFixed="true"/>
</overviewFormMapping>
```

**Task-level form mappings:**
```xml
<formMapping xmi:type="process:FormMapping" xmi:id="uuid" type="NONE">
  <targetForm xmi:type="expression:Expression" xmi:id="uuid" name="" content="" type="FORM_REFERENCE_TYPE" returnTypeFixed="true"/>
</formMapping>
```

**CRITICAL RULES:**
- Pool `formMapping` MUST have `type="NONE"`
- Pool `overviewFormMapping` does NOT use `type="NONE"`
- All human task `formMapping` elements MUST have `type="NONE"`
- Without `type="NONE"`, Maven build will fail with "No UIDesigner form is defined" error

### 9. Business Data Declaration

**CRITICAL**: Business data links process instances to BDM (Business Object Model) entities.

**Business data must be declared at Pool level** to be accessible throughout the process:

```xml
<elements xmi:type="process:Pool" xmi:id="pool-uuid" name="ProcessName" version="1.0">
  <!-- ... lanes, tasks, gateways ... -->

  <!-- Business Data declaration (AFTER all lanes/connections, BEFORE formMapping) -->
  <data xmi:type="process:BusinessObjectData" xmi:id="data-uuid"
        name="ficheExpressionBesoin" dataType="datatype-uuid"
        className="com.cnaf.recrutement.model.RHFicheExpressionBesoin">
    <defaultValue xmi:type="expression:Expression" xmi:id="default-uuid"
                  name="initializeFEB" content="..."
                  interpreter="GROOVY" type="TYPE_READ_ONLY_SCRIPT"
                  returnType="com.cnaf.recrutement.model.RHFicheExpressionBesoin">
      <referencedElements xmi:type="expression:Expression" xmi:id="ref1-uuid"
                          name="numeroFEB" content="numeroFEB"
                          type="TYPE_CONTRACT_INPUT" returnType="java.lang.String"/>
      <referencedElements xmi:type="expression:Expression" xmi:id="ref2-uuid"
                          name="emploi" content="emploi"
                          type="TYPE_CONTRACT_INPUT" returnType="java.lang.String"/>
      <!-- ... additional contract input references ... -->
    </defaultValue>
  </data>

  <formMapping xmi:type="process:FormMapping" xmi:id="uuid" type="NONE">
    <!-- ... -->
  </formMapping>
</elements>
```

**Business Data Attributes:**
- `xmi:id` - Unique identifier for the data element
- `name` - Variable name used in expressions (e.g., `ficheExpressionBesoin`)
- `dataType` - References the BusinessObjectType UUID in the datatypes section
- `className` - Fully qualified BDM class name (e.g., `com.cnaf.recrutement.model.RHFicheExpressionBesoin`)

**Data Initialization with defaultValue:**

The `defaultValue` expression initializes the business data when the process starts. Two approaches:

**Approach 1: Groovy script creating new instance (RECOMMENDED):**
```xml
<defaultValue xmi:type="expression:Expression" xmi:id="uuid"
              name="initializeFEB"
              content="import com.cnaf.recrutement.model.RHFicheExpressionBesoin;
import java.time.LocalDate;
import java.time.LocalDateTime;

def feb = new RHFicheExpressionBesoin();
feb.numeroFEB = numeroFEB;
feb.emploi = emploi;
feb.niveau = niveau;
feb.typeContrat = typeContrat;
feb.directionEmettrice = directionEmettrice;
feb.dateEmission = LocalDate.now();
feb.dateCreation = LocalDateTime.now();
feb.statut = 'Brouillon';
feb.createurUsername = '${apiAccessor.getProcessAPI().getProcessInstance(processInstanceId).getStartedBy()}';
return feb;"
              interpreter="GROOVY" type="TYPE_READ_ONLY_SCRIPT"
              returnType="com.cnaf.recrutement.model.RHFicheExpressionBesoin">
  <referencedElements xmi:type="process:ContractInput" xmi:id="uuid1"
                      name="numeroFEB">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-map1"/>
  </referencedElements>
  <referencedElements xmi:type="process:ContractInput" xmi:id="uuid2"
                      name="emploi">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-map2"/>
  </referencedElements>
  <!-- ... more contract input references ... -->
</defaultValue>
```

**Approach 2: Query existing instance:**
```xml
<defaultValue xmi:type="expression:Expression" xmi:id="uuid"
              name="retrieveExistingData"
              content="SELECT f FROM RHFicheExpressionBesoin f WHERE f.numeroFEB = :numeroFEB"
              interpreter="GROOVY" type="TYPE_QUERY_BUSINESS_DATA"
              returnType="com.cnaf.recrutement.model.RHFicheExpressionBesoin">
  <referencedElements xmi:type="expression:Expression" xmi:id="uuid-param"
                      name="numeroFEB" content="numeroFEB"
                      type="QUERY_PARAM_TYPE" returnType="java.lang.String">
    <referencedElements xmi:type="process:ContractInput" xmi:id="uuid-input"
                        name="numeroFEB">
      <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-map"/>
    </referencedElements>
  </referencedElements>
</defaultValue>
```

**Key Points:**
- Business data is initialized ONCE at pool instantiation using `defaultValue`
- The `defaultValue` script references pool contract inputs to populate initial values
- Use `TYPE_READ_ONLY_SCRIPT` with `interpreter="GROOVY"` for initialization scripts
- Use `TYPE_QUERY_BUSINESS_DATA` to retrieve existing BDM instances
- All contract inputs referenced in the script must be in `referencedElements`
- After initialization, use task operations to UPDATE business data fields
- The business data variable name (e.g., `ficheExpressionBesoin`) is used throughout the process

**DataTypes Declaration:**

Business data requires corresponding datatype declarations at MainProcess level:

```xml
<process:MainProcess xmi:id="uuid" name="ProcessName" version="1.0" bonitaModelVersion="9">
  <!-- ... pool, actors, configurations ... -->

  <!-- DataTypes (AFTER configurations, BEFORE notation:Diagram) -->
  <datatypes xmi:type="process:BooleanType" xmi:id="bool-uuid" name="Boolean"/>
  <datatypes xmi:type="process:DateType" xmi:id="date-uuid" name="Date"/>
  <datatypes xmi:type="process:IntegerType" xmi:id="int-uuid" name="Integer"/>
  <datatypes xmi:type="process:StringType" xmi:id="string-uuid" name="Text"/>
  <datatypes xmi:type="process:BusinessObjectType" xmi:id="bo-uuid" name="Business_Object"/>
</process:MainProcess>
```

**CRITICAL**: The `dataType` attribute in BusinessObjectData MUST reference the BusinessObjectType UUID (e.g., `bo-uuid` above).

### 10. Contract Elements

**CRITICAL**: Contracts define inputs for process instantiation (pool) and task execution (human tasks).

**Pool Contract** (process instantiation inputs):
```xml
<contract xmi:type="process:Contract" xmi:id="uuid">
  <inputs xmi:type="process:ContractInput" xmi:id="uuid" name="startDate" type="LOCALDATE">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid"/>
  </inputs>
  <inputs xmi:type="process:ContractInput" xmi:id="uuid" name="numberOfDays" type="INTEGER">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid"/>
  </inputs>
  <inputs xmi:type="process:ContractInput" xmi:id="uuid" name="requesterEmail">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid"/>
  </inputs>
</contract>
```

**Task Contract** (human task inputs with validation):
```xml
<contract xmi:type="process:Contract" xmi:id="uuid">
  <inputs xmi:type="process:ContractInput" xmi:id="uuid" name="status">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid"/>
  </inputs>
  <inputs xmi:type="process:ContractInput" xmi:id="uuid" name="comments">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid"/>
  </inputs>
  <constraints xmi:type="process:ContractConstraint" xmi:id="uuid"
               expression="if(status == &quot;rejected&quot;) { return !comments.isEmpty(); } return true;"
               errorMessage="Comments are mandatory when rejecting"
               name="mandatoryCommentsIfRejected">
    <inputNames>status</inputNames>
    <inputNames>comments</inputNames>
  </constraints>
</contract>
```

**Contract Input Types:**
- `TEXT` (default if no type specified) - String input
- `INTEGER` - Integer number
- `DECIMAL` - Decimal number
- `BOOLEAN` - true/false
- `LOCALDATE` - Date without time
- `LOCALDATETIME` - Date with time
- `FILE` - File upload
- `COMPLEX` - Business object (with mapping to BDM)

### 11. Contract Input Operations

**CRITICAL**: Each contract input must have an operation to map it to business data.

**IMPORTANT - Operations Placement:**
- Operations are ONLY valid inside Task elements (user tasks, service tasks)
- Operations are NOT valid at the Pool level
- For pool contract inputs, place operations in the FIRST task after the start event
- Operations must appear AFTER stepSummary and BEFORE loopCondition in task structure

Operations link contract inputs to business data fields using setter methods:

```xml
<operations xmi:type="expression:Operation" xmi:id="uuid">
  <leftOperand xmi:type="expression:Expression" xmi:id="uuid"
               name="vacationRequest" content="vacationRequest"
               type="TYPE_VARIABLE" returnType="com.company.hr.VacationRequest">
    <referencedElements xmi:type="process:BusinessObjectData" xmi:id="uuid"
                        name="vacationRequest"/>
  </leftOperand>
  <rightOperand xmi:type="expression:Expression" xmi:id="uuid"
                name="status" content="status" type="TYPE_CONTRACT_INPUT">
    <referencedElements xmi:type="process:ContractInput" xmi:id="uuid"
                        name="status"/>
  </rightOperand>
  <operator xmi:type="expression:Operator" xmi:id="uuid"
            type="JAVA_METHOD" expression="setStatus">
    <inputTypes>java.lang.String</inputTypes>
  </operator>
</operations>
```

**Operation Components:**
1. **leftOperand**: The business data variable to update (with dataType attribute)
2. **rightOperand**: Groovy script referencing contract input (TYPE_READ_ONLY_SCRIPT with interpreter="GROOVY")
3. **operator**: The setter method (e.g., setStatus, setStartDate)
4. **inputTypes**: Java type of the parameter

**CRITICAL**: Always use `TYPE_READ_ONLY_SCRIPT` with `interpreter="GROOVY"` for contract input references, not `TYPE_CONTRACT_INPUT`. The `name` attribute should be business-readable (e.g., "Approval Decision", "Decision CG", not "newScript()").

**Example for multiple fields:**
```xml
<!-- Set status field (String) -->
<operations xmi:type="expression:Operation" xmi:id="uuid1">
  <leftOperand xmi:type="expression:Expression" xmi:id="uuid-lop1"
               name="vacationRequest" content="vacationRequest"
               type="TYPE_VARIABLE" returnType="com.company.hr.VacationRequest">
    <referencedElements xmi:type="process:BusinessObjectData" xmi:id="uuid-bd1"
                        name="vacationRequest" dataType="uuid-datatype"/>
  </leftOperand>
  <rightOperand xmi:type="expression:Expression" xmi:id="uuid-rop1"
                name="newScript()" content="status" interpreter="GROOVY"
                type="TYPE_READ_ONLY_SCRIPT" returnType="java.lang.String">
    <referencedElements xmi:type="process:ContractInput" xmi:id="uuid-input1" name="status">
      <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-map1"/>
    </referencedElements>
  </rightOperand>
  <operator xmi:type="expression:Operator" xmi:id="uuid-opr1"
            type="JAVA_METHOD" expression="setStatus">
    <inputTypes>java.lang.String</inputTypes>
  </operator>
</operations>

<!-- Set approved field (Boolean) -->
<operations xmi:type="expression:Operation" xmi:id="uuid2">
  <leftOperand xmi:type="expression:Expression" xmi:id="uuid-lop2"
               name="vacationRequest" content="vacationRequest"
               type="TYPE_VARIABLE" returnType="com.company.hr.VacationRequest">
    <referencedElements xmi:type="process:BusinessObjectData" xmi:id="uuid-bd2"
                        name="vacationRequest" dataType="uuid-datatype"/>
  </leftOperand>
  <rightOperand xmi:type="expression:Expression" xmi:id="uuid-rop2"
                name="newScript()" content="approved" interpreter="GROOVY"
                type="TYPE_READ_ONLY_SCRIPT" returnType="java.lang.Boolean">
    <referencedElements xmi:type="process:ContractInput" xmi:id="uuid-input2"
                        name="approved" type="BOOLEAN">
      <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-map2"/>
    </referencedElements>
  </rightOperand>
  <operator xmi:type="expression:Operator" xmi:id="uuid-opr2"
            type="JAVA_METHOD" expression="setApproved">
    <inputTypes>java.lang.Boolean</inputTypes>
  </operator>
</operations>
```

### 12. Notation Diagram

Include visual layout in notation:Diagram section:
- **CRITICAL**: Use horizontal left-to-right flow for readability
- All lanes should have consistent height (typically 150px)
- Tasks spaced 150-200px apart horizontally for clarity
- Elements centered vertically within lanes (y=20-30 for 150px lanes)
- Pool dimensions should accommodate all elements with appropriate margins
- **CRITICAL FOR GATEWAYS**: Minimum 100-150px horizontal spacing between gateway and next element
  * Prevents transition label overlap (e.g., "Oui", "Non", "Défaut")
  * Gateway at x=500 → End event at x=640 minimum (140px gap)
  * Gateway at x=500 → Next task at x=700 minimum (200px gap)
- Defines positions and sizes of all BPMN elements
- See detailed guidelines in `steps/03-generate-proc.md` section 21

#### **CRITICAL**: Label Decoration Nodes

**Every visual element in the notation section MUST have a label decoration node** to display its name. Without these, the process diagram will show blank elements in Bonita Studio.

**Element Type Mapping:**

| BPMN Element | Notation Type | Label Decoration Type | Visible | Notes |
|--------------|---------------|----------------------|---------|-------|
| Lane | `type="3007"` (Node) | `type="5007"` (DecorationNode) | true | Lane name label |
| Task | `type="3005"` (Shape) | `type="5005"` (DecorationNode) | true | Task name label |
| Start Event | `type="3002"` (Shape) | `type="5024"` (DecorationNode) | true | Event name label |
| End Event | `type="3003"` (Shape) | `type="5025"` (DecorationNode) | true | Event name label |
| XOR Gateway | `type="3008"` (Shape) | `type="5026"` (DecorationNode) | true | Gateway name label |

**Structure Pattern:**

```xml
<!-- Lane Structure -->
<children xmi:type="notation:Node" xmi:id="uuid1" type="3007" element="lane-uuid">
  <children xmi:type="notation:DecorationNode" xmi:id="uuid2" type="5007"/>
  <children xmi:type="notation:DecorationNode" xmi:id="uuid3" type="7002">
    <!-- Lane contents (tasks, events, gateways) go here -->
  </children>
  <layoutConstraint xmi:type="notation:Bounds" xmi:id="uuid4" y="0" width="1400" height="150"/>
</children>

<!-- Task Structure -->
<children xmi:type="notation:Shape" xmi:id="uuid5" type="3005" element="task-uuid"
          fontName="Sans" fillColor="14334392" lineColor="10710316">
  <children xmi:type="notation:DecorationNode" xmi:id="uuid6" type="5005" element="task-uuid"/>
  <layoutConstraint xmi:type="notation:Bounds" xmi:id="uuid7" x="150" y="30" width="120" height="60"/>
</children>

<!-- Start Event Structure -->
<children xmi:type="notation:Shape" xmi:id="uuid8" type="3002" element="start-uuid" fontName="Sans">
  <children xmi:type="notation:DecorationNode" xmi:id="uuid9" type="5024" element="start-uuid">
    <layoutConstraint xmi:type="notation:Location" xmi:id="uuid10" y="5"/>
  </children>
  <layoutConstraint xmi:type="notation:Bounds" xmi:id="uuid11" x="50" y="60"/>
</children>

<!-- End Event Structure -->
<children xmi:type="notation:Shape" xmi:id="uuid12" type="3003" element="end-uuid" fontName="Sans">
  <children xmi:type="notation:DecorationNode" xmi:id="uuid13" type="5025" element="end-uuid">
    <layoutConstraint xmi:type="notation:Location" xmi:id="uuid14" y="5"/>
  </children>
  <layoutConstraint xmi:type="notation:Bounds" xmi:id="uuid15" x="640" y="60"/>
</children>

<!-- XOR Gateway Structure -->
<children xmi:type="notation:Shape" xmi:id="uuid16" type="3008" element="gateway-uuid" fontName="Sans">
  <children xmi:type="notation:DecorationNode" xmi:id="uuid17" type="5026" element="gateway-uuid">
    <layoutConstraint xmi:type="notation:Location" xmi:id="uuid18" y="5"/>
  </children>
  <layoutConstraint xmi:type="notation:Bounds" xmi:id="uuid19" x="490" y="45" width="30" height="30"/>
</children>
```

**Key Points:**

- Each `notation:Shape` or `notation:Node` element references a process element via the `element` attribute
- The label `DecorationNode` MUST have the same `element` attribute value
- All element labels are visible by default (lanes, tasks, start events, end events, gateways)
- To hide a label, add `visible="false"` attribute to the DecorationNode (generally not recommended)
- Tasks use colors: `fillColor="14334392"` (light blue) and `lineColor="10710316"` (dark border)
- Edges (connectors for sequence flows) also need label DecorationNodes with `type="6001"`

**Without these label decoration nodes, the process will build successfully but appear broken in Studio with no visible element names.**

## Example Process Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xmi:XMI xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI"
  xmlns:process="http://www.bonitasoft.org/ns/bpm/process"
  xmlns:notation="http://www.eclipse.org/gmf/runtime/1.0.3/notation"
  xmlns:expression="http://www.bonitasoft.org/ns/bpm/expression"
  xmlns:actormapping="http://www.bonitasoft.org/ns/actormapping/6.0"
  xmlns:configuration="http://www.bonitasoft.org/ns/bpm/configuration">

  <process:MainProcess xmi:id="uuid-main" name="MyProcess" bonitaModelVersion="9">
    <elements xmi:type="process:Pool" xmi:id="uuid-pool" name="MyProcess">

      <!-- Lane for actor -->
      <elements xmi:type="process:Lane" xmi:id="uuid-lane1" name="Manager lane" actor="uuid-actor1">

        <!-- Start Event -->
        <elements xmi:type="process:StartEvent" xmi:id="uuid-start" name="Start" outgoing="uuid-flow1">
          <dynamicLabel xmi:type="expression:Expression" xmi:id="uuid-expr1" name="" content="" returnTypeFixed="true"/>
          <dynamicDescription xmi:type="expression:Expression" xmi:id="uuid-expr2" name="" content="" returnTypeFixed="true"/>
          <stepSummary xmi:type="expression:Expression" xmi:id="uuid-expr3" name="" content="" returnTypeFixed="true"/>
        </elements>

        <!-- User Task -->
        <elements xmi:type="process:Task" xmi:id="uuid-task1" name="Review Request"
                 incoming="uuid-flow1" outgoing="uuid-flow2" actor="uuid-actor1">
          <dynamicLabel xmi:type="expression:Expression" xmi:id="uuid-expr4" name="" content="" returnTypeFixed="true"/>
          <dynamicDescription xmi:type="expression:Expression" xmi:id="uuid-expr5" name="" content="" returnTypeFixed="true"/>
          <stepSummary xmi:type="expression:Expression" xmi:id="uuid-expr6" name="" content="" returnTypeFixed="true"/>
        </elements>

        <!-- End Event -->
        <elements xmi:type="process:EndEvent" xmi:id="uuid-end" name="End" incoming="uuid-flow2">
          <dynamicLabel xmi:type="expression:Expression" xmi:id="uuid-expr7" name="" content="" returnTypeFixed="true"/>
          <dynamicDescription xmi:type="expression:Expression" xmi:id="uuid-expr8" name="" content="" returnTypeFixed="true"/>
          <stepSummary xmi:type="expression:Expression" xmi:id="uuid-expr9" name="" content="" returnTypeFixed="true"/>
        </elements>

      </elements>

      <!-- Connections -->
      <connections xmi:type="process:SequenceFlow" xmi:id="uuid-flow1"
                   target="uuid-task1" source="uuid-start"/>
      <connections xmi:type="process:SequenceFlow" xmi:id="uuid-flow2"
                   target="uuid-end" source="uuid-task1"/>

      <!-- Actors -->
      <actors xmi:type="process:Actor" xmi:id="uuid-actor1"
              name="Manager" initiator="true"/>

      <!-- Configuration -->
      <configurations xmi:type="configuration:Configuration" xmi:id="uuid-config"
                      name="presales" version="9" username="walter.bates">
        <actorMappings xmi:type="actormapping:ActorMappingsType" xmi:id="uuid-actormapping">
          <actorMapping xmi:type="actormapping:ActorMapping" xmi:id="uuid-mapping1" name="Manager">
            <groups xmi:type="actormapping:Groups" xmi:id="uuid-groups1"/>
            <memberships xmi:type="actormapping:Membership" xmi:id="uuid-members1"/>
            <roles xmi:type="actormapping:Roles" xmi:id="uuid-roles1">
              <role>manager</role>
            </roles>
            <users xmi:type="actormapping:Users" xmi:id="uuid-users1"/>
          </actorMapping>
        </actorMappings>
      </configurations>

      <!-- Form Mappings -->
      <formMapping xmi:type="process:FormMapping" xmi:id="uuid-form1" type="NONE">
        <targetForm xmi:type="expression:Expression" xmi:id="uuid-formexpr1"
                    name="" content="" type="FORM_REFERENCE_TYPE" returnTypeFixed="true"/>
      </formMapping>
      <overviewFormMapping xmi:type="process:FormMapping" xmi:id="uuid-form2">
        <targetForm xmi:type="expression:Expression" xmi:id="uuid-formexpr2"
                    name="" content="" type="FORM_REFERENCE_TYPE" returnTypeFixed="true"/>
      </overviewFormMapping>

      <!-- Contract -->
      <contract xmi:type="process:Contract" xmi:id="uuid-contract"/>

    </elements>
  </process:MainProcess>

  <!-- Notation for visual layout -->
  <notation:Diagram xmi:id="uuid-diagram" type="Process" element="uuid-main" name="MyProcess">
    <!-- Visual elements with coordinates -->
  </notation:Diagram>

</xmi:XMI>
```

## Common Errors and Solutions

### Error: "bonitaModelVersion incorrect"
**Cause**: Using wrong model version
**Solution**: Always use `bonitaModelVersion="9"` for Bonita 10.x projects (this is the BPMN model version, not the runtime version)

### Error: "Invalid IDREF"
**Cause**: Referencing non-existent xmi:id
**Solution**: Ensure all IDREF attributes point to valid xmi:id values

### Error: "Duplicate xmi:id"
**Cause**: Reusing same UUID for multiple elements
**Solution**: Generate unique UUIDs for each element

### Error: "Missing required expression elements"
**Cause**: Flow node missing dynamicLabel, dynamicDescription, or stepSummary
**Solution**: Add all three expression elements to every flow node

### Error: "Invalid namespace"
**Cause**: Missing or incorrect namespace declaration
**Solution**: Include all required namespaces in XMI root element

### Error: "File already exists"
**Cause**: Process file with same name and version already exists in app/diagrams
**Solution**: Automatically increment version number (1.0 → 1.1 → 1.2) until finding available filename

### Error: "Process deadlock at XOR gateway"
**Cause**: XOR gateway has no default transition, and no conditional flow matched
**Solution**: Ensure every XORGateway has exactly one outgoing SequenceFlow with `isDefault="true"`

### Error: "Contract input not mapped to business data"
**Cause**: Contract inputs defined but no operations to set business data values
**Solution**: For each contract input, create an operation element with leftOperand (business data), rightOperand (contract input), and operator (setter method)

### Error: "Missing contract on human task"
**Cause**: Human task has no contract definition
**Solution**: Add contract element to each human task with appropriate inputs based on what data the task needs to collect

### Error: "Contract constraint validation failed"
**Cause**: Contract constraint expression is invalid or references non-existent inputs
**Solution**: Ensure constraint expression uses valid Groovy syntax and only references inputs listed in inputNames

### Error: "Target of sequenceflow is null"
**Cause**: One or more sequence flows are malformed (usually self-closing tags without required child elements)
**Solution**: All sequence flows MUST have `<decisionTable>` and `<condition>` child elements, even if empty:
```xml
<connections xmi:type="process:SequenceFlow" xmi:id="uuid" target="uuid" source="uuid">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="uuid"/>
  <condition xmi:type="expression:Expression" xmi:id="uuid" name="" content="" returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>
```
Never use self-closing sequence flows: `<connections ... />` ❌

### Error: "This sequence flow has no target" (Studio validation)
**Cause**: Complex structural issues with the generated .proc file that pass programmatic validation but fail Studio validation
**Solution**: Regenerate the file ensuring all required structural elements are present:
1. Verify all sequence flows have `<decisionTable>` and `<condition>` child elements (not self-closing)
2. Ensure all notation elements have proper label decoration nodes (type="5005", "5024", "5025", "5026")
3. Verify all `element` attributes in notation section reference valid process element IDs
4. Check that all edges have proper `source` and `target` attributes pointing to notation element IDs
5. Reference working samples in `.claude/process-samples/` for correct structure patterns

### Error: "Unresolved reference to BusinessObjectData"
**Cause**: Missing BusinessObjectType datatype definition at MainProcess level
**Solution**: Add datatype definition before the closing `</process:MainProcess>` tag:
```xml
    </elements>
    <datatypes xmi:type="process:BusinessObjectType" xmi:id="uuid-matching-dataType-attribute" name="Business_Object"/>
  </process:MainProcess>
```

### Error: "BusinessObjectDataImpl cannot be cast to DataType"
**Cause**: Using same UUID for both element `xmi:id` and `dataType` attribute in BusinessObjectData references
**Solution**: The `xmi:id` must be unique per element, while `dataType` should reference the BusinessObjectType definition:
```xml
<!-- WRONG: same UUID for xmi:id and dataType -->
<referencedElements xmi:type="process:BusinessObjectData" xmi:id="abc-123"
                    name="myData" dataType="abc-123"/>

<!-- CORRECT: unique xmi:id, dataType references BusinessObjectType -->
<referencedElements xmi:type="process:BusinessObjectData" xmi:id="unique-uuid-1"
                    name="myData" dataType="uuid-of-BusinessObjectType"/>
```

## Next Steps

After generating process diagram:
1. Review the generated .proc file for completeness
2. Validate XML structure using xmllint
3. Build project with Maven to verify compilation
4. Import into Bonita Studio to visualize
5. Deploy BDM (if not already deployed)
6. Import organization (if not already deployed)
7. Create UI forms for:
   - Pool instantiation form (matching pool contract inputs)
   - Task forms (matching task contract inputs with validation)
8. Test process execution with various scenarios
9. Verify BDM data persistence and gateway conditions

## Notes

- The skill generates production-ready process diagrams with contracts and business data integration
- Generated processes include:
  - XOR gateways with default transitions to prevent deadlocks
  - Pool and task contracts with business data mappings
  - BDM instantiation using initialization scripts (not operations)
  - Task operations to update BDM from task contract inputs
  - Proper form mappings with type="NONE" to avoid build errors
  - Readable horizontal visual layout with consistent lane heights
- Forms and connectors can be added in Bonita Studio
- The skill references real process samples from `.claude/process-samples/` for accurate structure
- **Visual layout uses horizontal left-to-right flow with 150px lanes and 150-200px task spacing**
- Always validate generated files before importing into Studio

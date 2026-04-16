# Step 3: Generate Process Diagram XML

Generate the complete Bonita Process Diagram (.proc) XML file using extracted workflow and generated UUIDs.

## Prerequisites

- Extracted workflow information from Step 1
- Generated UUIDs from Step 2
- Process name extracted from analysis document
- Output directory: `app/diagrams/` (MANDATORY)

## Process

### 0. Check for Existing Files and Determine Version

**CRITICAL STEP:** Before generating XML, check for version collisions:

1. Extract process name from analysis (e.g., "ValidationRecrutement")
2. Check if `app/diagrams/ProcessName-1.0.proc` exists
3. If exists, increment MINOR version: 1.0 → 1.1 → 1.2 → ...
4. Continue checking until finding an available filename
5. Use the next available version number in the generated file

**Example bash check:**
```bash
PROCESS_NAME="ValidationRecrutement"
VERSION="1.0"
MINOR=0

while [ -f "app/diagrams/${PROCESS_NAME}-1.${MINOR}.proc" ]; do
  MINOR=$((MINOR + 1))
done

VERSION="1.${MINOR}"
OUTPUT_FILE="app/diagrams/${PROCESS_NAME}-${VERSION}.proc"
echo "Using version: $VERSION"
```

**Version Format:** `ProcessName-MAJOR.MINOR.proc`
- Start with version `1.0` for new processes
- Increment MINOR version for each collision: 1.0 → 1.1 → 1.2
- Increment MAJOR version for breaking changes (manual decision)


### 1. Create XMI Root Structure

Start with XML declaration and XMI root element with all required namespaces:

```xml
<?xml version="1.0" encoding="UTF-8"?>
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

### 2. Create MainProcess

Add MainProcess with bonitaModelVersion="9":

```xml
<process:MainProcess xmi:id="[UUID_MAINPROCESS]" name="[ProcessName]" bonitaModelVersion="9">
```

### 3. Create Pool

Add Pool element inside MainProcess:

```xml
<elements xmi:type="process:Pool" xmi:id="[UUID_POOL]" name="[ProcessName]">
```

### 4. Add Lanes for Each Actor

For each actor, create a Lane:

```xml
<elements xmi:type="process:Lane" xmi:id="[UUID_LANE]" name="[ActorName] lane" actor="[UUID_ACTOR]">
```

Place the appropriate tasks inside each lane based on actor assignment from Step 1.

### 5. Add Start Event

Inside the first lane (initiator's lane), add StartEvent:

```xml
<elements xmi:type="process:StartEvent" xmi:id="[UUID_START]" name="Start" outgoing="[UUID_FLOW_TO_FIRST_TASK]">
  <dynamicLabel xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <dynamicDescription xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <stepSummary xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
</elements>
```

### 6. Add Tasks

For each task from Step 1, create appropriate task element:

**User Task:**
```xml
<elements xmi:type="process:Task" xmi:id="[UUID_TASK]" name="[TaskName]"
         incoming="[UUID_INCOMING_FLOW]" outgoing="[UUID_OUTGOING_FLOW]" overrideActorsOfTheLane="false">
  <dynamicLabel xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <dynamicDescription xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <stepSummary xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <loopCondition xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnType="java.lang.Boolean" returnTypeFixed="true"/>
  <loopMaximum xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnType="java.lang.Integer" returnTypeFixed="true"/>
  <cardinalityExpression xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnType="java.lang.Integer" returnTypeFixed="true"/>
  <iteratorExpression xmi:type="expression:Expression" xmi:id="[UUID]" name="multiInstanceIterator" content="multiInstanceIterator" type="MULTIINSTANCE_ITERATOR_TYPE" returnType="java.lang.Object" returnTypeFixed="true"/>
  <completionCondition xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnType="java.lang.Boolean" returnTypeFixed="true"/>
  <formMapping xmi:type="process:FormMapping" xmi:id="[UUID]" type="NONE">
    <targetForm xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" type="FORM_REFERENCE_TYPE" returnTypeFixed="true"/>
  </formMapping>
  <contract xmi:type="process:Contract" xmi:id="[UUID]">
    <!-- Add contract inputs based on what data this task collects -->
    <inputs xmi:type="process:ContractInput" xmi:id="[UUID]" name="[inputName]" type="[TYPE]">
      <mapping xmi:type="process:ContractInputMapping" xmi:id="[UUID]"/>
    </inputs>
    <!-- Add contract constraints if validation is needed -->
    <constraints xmi:type="process:ContractConstraint" xmi:id="[UUID]"
                 expression="[validation expression]"
                 errorMessage="[error message]"
                 name="[constraintName]">
      <inputNames>[inputName1]</inputNames>
      <inputNames>[inputName2]</inputNames>
    </constraints>
  </contract>
  <expectedDuration xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnType="java.lang.Long" returnTypeFixed="true"/>
</elements>
```

**Task Contract Guidelines:**
- Include inputs for all fields the user needs to provide/update at this step
- Add constraints for validation rules (e.g., mandatory fields, conditional requirements)
- Keep constraint expressions simple and readable
- Use appropriate input types matching the BDM field types

**Service/Automatic Task:**
```xml
<elements xmi:type="process:ServiceTask" xmi:id="[UUID_TASK]" name="[TaskName]"
         incoming="[UUID_INCOMING_FLOW]" outgoing="[UUID_OUTGOING_FLOW]">
  <dynamicLabel xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <dynamicDescription xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <stepSummary xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <loopCondition xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnType="java.lang.Boolean" returnTypeFixed="true"/>
  <loopMaximum xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnType="java.lang.Integer" returnTypeFixed="true"/>
  <cardinalityExpression xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnType="java.lang.Integer" returnTypeFixed="true"/>
  <iteratorExpression xmi:type="expression:Expression" xmi:id="[UUID]" name="multiInstanceIterator" content="multiInstanceIterator" type="MULTIINSTANCE_ITERATOR_TYPE" returnType="java.lang.Object" returnTypeFixed="true"/>
  <completionCondition xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnType="java.lang.Boolean" returnTypeFixed="true"/>
</elements>
```

**Note:**
- Place tasks in the lane of their assigned actor
- User tasks (human tasks) use `process:Task` and include formMapping, contract, and expectedDuration
- Service tasks (automatic tasks) use `process:ServiceTask` and don't have formMapping, contract, or expectedDuration
- The `overrideActorsOfTheLane="false"` attribute means the task uses the lane's actor

### 7. Add Gateways

For each gateway from Step 1:

**XOR Gateway (Exclusive - most common):**
```xml
<elements xmi:type="process:XORGateway" xmi:id="[UUID_GATEWAY]" name="[GatewayName]"
         incoming="[UUID_INCOMING_FLOW]"
         outgoing="[UUID_OUTGOING_FLOW1] [UUID_OUTGOING_FLOW2]">
  <dynamicLabel xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <dynamicDescription xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <stepSummary xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
</elements>
```

**AND Gateway (Parallel):**
```xml
<elements xmi:type="process:ANDGateway" xmi:id="[UUID_GATEWAY]" name="[GatewayName]"
         incoming="[UUID_INCOMING_FLOW]"
         outgoing="[UUID_OUTGOING_FLOW1] [UUID_OUTGOING_FLOW2]">
  <dynamicLabel xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <dynamicDescription xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <stepSummary xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
</elements>
```

**Gateway Types:**
- `process:XORGateway` - Exclusive, only one path taken (most common for decision points)
- `process:ANDGateway` - Parallel, all paths taken simultaneously
- `process:InclusiveGateway` - Inclusive, one or more paths taken based on conditions

### 8. Add End Events

For each end point in the process:

```xml
<elements xmi:type="process:EndEvent" xmi:id="[UUID_END]" name="End" incoming="[UUID_INCOMING_FLOW]">
  <dynamicLabel xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <dynamicDescription xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
  <stepSummary xmi:type="expression:Expression" xmi:id="[UUID]" name="" content="" returnTypeFixed="true"/>
</elements>
```

Place end events in the appropriate lanes.

### 9. Close Lanes

Close all lane elements:

```xml
      </elements> <!-- End of Lane -->
```

### 10. Add Sequence Flows (Connections)

After lanes, add all connections based on the flow from Step 1.

**Standard Flow (no condition):**
```xml
<connections xmi:type="process:SequenceFlow" xmi:id="[UUID_FLOW]"
             target="[UUID_TARGET]" source="[UUID_SOURCE]">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="[UUID]"/>
  <condition xmi:type="expression:Expression" xmi:id="[UUID]" name=""
             content="" returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>
```

**Conditional Flow from XOR Gateway:**
```xml
<connections xmi:type="process:SequenceFlow" xmi:id="[UUID_FLOW]"
             name="[ConditionLabel]" target="[UUID_TARGET]" source="[UUID_GATEWAY]">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="[UUID]"/>
  <condition xmi:type="expression:Expression" xmi:id="[UUID]" name=""
             content="[BDM_ENTITY].[field] == [value]"
             interpreter="GROOVY" returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>
```

**CRITICAL**: Conditions MUST reference BDM entity fields, NOT local variables.
- ❌ WRONG: `content="decision == true"` (references non-existent local variable)
- ✅ CORRECT: `content="ficheExpressionBesoin.decisionRH == true"` (references BDM field set in previous task)

**CRITICAL RULES - XOR Gateway Flows:**

1. Every XORGateway MUST have exactly ONE outgoing flow with `isDefault="true"`. This ensures the process doesn't deadlock if no conditional flows evaluate to true.
2. Default flows MUST NOT have a name attribute - this avoids label clutter in diagrams.
3. Gateway conditions MUST reference BDM entity fields set in previous tasks, NOT local contract input variables.
4. All conditions MUST use `interpreter="GROOVY"` and `returnType="java.lang.Boolean"`.

```xml
<connections xmi:type="process:SequenceFlow" xmi:id="[UUID_FLOW]"
             target="[UUID_TARGET]" source="[UUID_GATEWAY]" isDefault="true">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="[UUID]"/>
  <condition xmi:type="expression:Expression" xmi:id="[UUID]" name=""
             content="" returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>
```

**Example - XOR Gateway with 2 conditional flows + 1 default:**

```xml
<!-- Gateway -->
<elements xmi:type="process:XORGateway" xmi:id="uuid-gw1" name="Decision"
         incoming="uuid-flow-in" outgoing="uuid-flow-yes uuid-flow-no uuid-flow-default">
  <!-- expression elements omitted for brevity -->
</elements>

<!-- Conditional flow: Yes -->
<connections xmi:type="process:SequenceFlow" xmi:id="uuid-flow-yes"
             name="Yes" target="uuid-task-approved" source="uuid-gw1">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="uuid-dt1"/>
  <condition xmi:type="expression:Expression" xmi:id="uuid-cond1"
             name="Yes" content="status == 'approved'"
             returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>

<!-- Conditional flow: No -->
<connections xmi:type="process:SequenceFlow" xmi:id="uuid-flow-no"
             name="No" target="uuid-task-rejected" source="uuid-gw1">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="uuid-dt2"/>
  <condition xmi:type="expression:Expression" xmi:id="uuid-cond2"
             name="No" content="status == 'rejected'"
             returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>

<!-- DEFAULT FLOW - MANDATORY for XOR gateways (NO name attribute) -->
<connections xmi:type="process:SequenceFlow" xmi:id="uuid-flow-default"
             target="uuid-end" source="uuid-gw1" isDefault="true">
  <decisionTable xmi:type="decision:DecisionTable" xmi:id="uuid-dt3"/>
  <condition xmi:type="expression:Expression" xmi:id="uuid-cond3"
             name="" content="" returnType="java.lang.Boolean" returnTypeFixed="true"/>
</connections>
```

**Note**: ANDGateway (parallel) does NOT require a default flow, as all outgoing flows are taken.

### 11. Add Form Mappings

Add form mapping elements to the Pool:

```xml
<formMapping xmi:type="process:FormMapping" xmi:id="[UUID]" type="NONE">
  <targetForm xmi:type="expression:Expression" xmi:id="[UUID]" name="" content=""
              type="FORM_REFERENCE_TYPE" returnTypeFixed="true"/>
</formMapping>
<overviewFormMapping xmi:type="process:FormMapping" xmi:id="[UUID]">
  <targetForm xmi:type="expression:Expression" xmi:id="[UUID]" name="" content=""
              type="FORM_REFERENCE_TYPE" returnTypeFixed="true"/>
</overviewFormMapping>
```

**IMPORTANT:**
- Pool `formMapping` requires `type="NONE"`
- Pool `overviewFormMapping` does NOT use `type="NONE"`
- Task `formMapping` requires `type="NONE"` (see task template in Step 6)

### 12. Add Actors

Define all actors:

```xml
<actors xmi:type="process:Actor" xmi:id="[UUID_ACTOR]"
        documentation="[Description]"
        name="[ActorName]"
        initiator="[true/false]"/>
```

Set `initiator="true"` for the actor who starts the process (only one).

### 13. Add Configuration

Add presales configuration with actor mappings:

```xml
<configurations xmi:type="configuration:Configuration" xmi:id="[UUID_CONFIG]"
                name="presales" version="9" username="walter.bates">
  <actorMappings xmi:type="actormapping:ActorMappingsType" xmi:id="[UUID_ACTORMAPPINGS]">

    <!-- For each actor -->
    <actorMapping xmi:type="actormapping:ActorMapping" xmi:id="[UUID_MAPPING]" name="[ActorName]">
      <groups xmi:type="actormapping:Groups" xmi:id="[UUID]"/>
      <memberships xmi:type="actormapping:Membership" xmi:id="[UUID]"/>
      <roles xmi:type="actormapping:Roles" xmi:id="[UUID]">
        <role>[roleName]</role>
      </roles>
      <users xmi:type="actormapping:Users" xmi:id="[UUID]"/>
    </actorMapping>

  </actorMappings>
  <processDependencies xmi:type="configuration:FragmentContainer" xmi:id="[UUID]" id="CONNECTOR"/>
  <processDependencies xmi:type="configuration:FragmentContainer" xmi:id="[UUID]" id="ACTOR_FILTER"/>
  <processDependencies xmi:type="configuration:FragmentContainer" xmi:id="[UUID]" id="OTHER"/>
</configurations>
```

**CRITICAL - Actor Role Mapping:**
- Read the organization file (typically `app/organizations/*.xml`) to identify correct role names
- Use role names from `<roles><role name="...">` elements, NOT group names from `<groups><group name="...">`
- Example: Use `valideur_rh` (role), NOT `rh` (group)
- Multiple roles can be assigned to a single actor:
```xml
<roles xmi:type="actormapping:Roles" xmi:id="[UUID]">
  <role>valideur_rh</role>
  <role>valideur_final_rh</role>
</roles>
```
- Map each actor to their role from Step 1 AND the organization file.

### 14. Add Pool Contract

**CRITICAL**: The pool contract defines inputs required for process instantiation.

Generate contract inputs based on business data from the analysis document. Each BDM entity field that needs to be set at process start should have a corresponding contract input.

```xml
<contract xmi:type="process:Contract" xmi:id="[UUID_CONTRACT]">
  <!-- Contract inputs based on BDM fields -->
  <inputs xmi:type="process:ContractInput" xmi:id="[UUID]" name="[fieldName]" type="[TYPE]">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="[UUID]"/>
  </inputs>
  <!-- Add more inputs as needed -->
</contract>
```

**Contract Input Types:**
- No type attribute = `TEXT` (String)
- `type="INTEGER"` - Integer number
- `type="DECIMAL"` - Decimal number (Double)
- `type="BOOLEAN"` - Boolean (true/false)
- `type="LOCALDATE"` - Date without time
- `type="LOCALDATETIME"` - Date with time
- `type="LONG"` - Long integer
- `type="FILE"` - File upload

**Example** (for a vacation request process):
```xml
<contract xmi:type="process:Contract" xmi:id="uuid-contract">
  <inputs xmi:type="process:ContractInput" xmi:id="uuid-input1"
          name="startDate" type="LOCALDATE">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-mapping1"/>
  </inputs>
  <inputs xmi:type="process:ContractInput" xmi:id="uuid-input2"
          name="returnDate" type="LOCALDATE">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-mapping2"/>
  </inputs>
  <inputs xmi:type="process:ContractInput" xmi:id="uuid-input3"
          name="numberOfDays" type="INTEGER">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-mapping3"/>
  </inputs>
  <inputs xmi:type="process:ContractInput" xmi:id="uuid-input4" name="requesterEmail">
    <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-mapping4"/>
  </inputs>
</contract>
```

**Guidelines:**
- Include all fields needed to create/initialize the main business object
- Use appropriate types matching the BDM field types
- Keep input names consistent with BDM field names (camelCase)
- Simple contracts (< 5 inputs) are easier to maintain

### 15. Add Business Object Data with Initialization Script

**CRITICAL - BDM Instantiation Strategy:**
- BDM instantiation MUST be done in the business data initialization script, NOT in task operations
- The initialization script runs when the process starts and has access to pool contract inputs
- Task operations should only UPDATE existing business data, not create it

**Business Object Data Declaration:**
```xml
<data xmi:type="process:BusinessObjectData" xmi:id="[UUID]"
      name="[variableName]" dataType="[dataTypeUUID]"
      className="[fully.qualified.ClassName]">
  <defaultValue xmi:type="expression:Expression" xmi:id="[UUID]"
                name="[initScriptName]" content="[groovyScriptWithXMLEscaping]"
                interpreter="GROOVY" type="TYPE_READ_ONLY_SCRIPT"
                returnType="[fully.qualified.ClassName]" returnTypeFixed="true"/>
</data>
```

**Groovy Initialization Script Requirements:**
1. **Import Required Classes:**
   - `import java.time.LocalDate`
   - `import java.time.LocalDateTime`
   - Any BDM class imports

2. **Create BDM Instance:**
   - Use `new` keyword to instantiate the BDM object
   - Set all required fields from the BDM model

3. **Use Pool Contract Inputs:**
   - Contract input variables are directly accessible in the script
   - Variable names match contract input names exactly

4. **Set System Fields:**
   - Generate unique IDs, timestamps, current user
   - Use Bonita API for process context: `apiAccessor.getProcessAPI().getProcessInstance(processInstanceId).getStartedBy()`

5. **Return the Object:**
   - Script must return the fully initialized BDM object

**Example - VacationRequest with Pool Contract Inputs:**
```xml
<data xmi:type="process:BusinessObjectData" xmi:id="uuid-bd"
      name="vacationRequest" dataType="uuid-datatype"
      className="com.company.hr.VacationRequest">
  <defaultValue xmi:type="expression:Expression" xmi:id="uuid-defval"
                name="createNewVacationRequest"
                content="import java.time.LocalDate&#10;import java.time.LocalDateTime&#10;&#10;// Generate unique request number&#10;def requestNumber = &quot;VR-&quot; + LocalDate.now().getYear() + &quot;-&quot; + String.format(&quot;%04d&quot;, (Math.random() * 10000) as Integer)&#10;&#10;// Create new VacationRequest instance&#10;def vr = new com.company.hr.VacationRequest()&#10;vr.requestNumber = requestNumber&#10;vr.startDate = startDate&#10;vr.returnDate = returnDate&#10;vr.numberOfDays = numberOfDays&#10;vr.status = &quot;Pending&quot;&#10;vr.requestDate = LocalDate.now()&#10;vr.requesterUsername = apiAccessor.getProcessAPI().getProcessInstance(processInstanceId).getStartedBy()&#10;&#10;return vr"
                interpreter="GROOVY" type="TYPE_READ_ONLY_SCRIPT"
                returnType="com.company.hr.VacationRequest" returnTypeFixed="true"/>
</data>
```

**XML Escaping in Groovy Scripts:**
- Newlines: `&#10;` or `&#xD;&#xA;`
- Double quotes: `&quot;`
- Less than: `&lt;`
- Greater than: `&gt;`
- Ampersand: `&amp;`

**Script Example (Unescaped for Readability):**
```groovy
import java.time.LocalDate
import java.time.LocalDateTime

// Generate unique request number
def requestNumber = "VR-" + LocalDate.now().getYear() + "-" + String.format("%04d", (Math.random() * 10000) as Integer)

// Create new VacationRequest instance
def vr = new com.company.hr.VacationRequest()
vr.requestNumber = requestNumber
vr.startDate = startDate           // From pool contract input
vr.returnDate = returnDate         // From pool contract input
vr.numberOfDays = numberOfDays     // From pool contract input
vr.status = "Pending"
vr.requestDate = LocalDate.now()
vr.requesterUsername = apiAccessor.getProcessAPI().getProcessInstance(processInstanceId).getStartedBy()

return vr
```

**IMPORTANT Notes:**
- The script has access to all pool contract inputs as variables
- Variable names must match contract input names exactly
- Script runs BEFORE the first task executes
- Return type MUST match the BDM class name

### 16. Add Task Contract Operations (Optional)

**When to Use Operations:**
- To UPDATE business data from task contract inputs
- NOT for initial BDM creation (use init script instead)
- Operations are valid ONLY inside Task elements

**Operation Structure:**

**CRITICAL**: Always use Groovy scripts for contract input references in operations. This is required for proper type handling in Bonita Studio.

```xml
<operations xmi:type="expression:Operation" xmi:id="[UUID]">
  <leftOperand xmi:type="expression:Expression" xmi:id="[UUID]"
               name="[businessObjectVar]" content="[businessObjectVar]"
               type="TYPE_VARIABLE" returnType="[fully.qualified.ClassName]">
    <referencedElements xmi:type="process:BusinessObjectData" xmi:id="[newUUID]"
                        name="[businessObjectVar]" dataType="[dataTypeUUID]"/>
  </leftOperand>
  <rightOperand xmi:type="expression:Expression" xmi:id="[UUID]"
                name="[Business Readable Name]" content="[contractInputName]"
                interpreter="GROOVY" type="TYPE_READ_ONLY_SCRIPT"
                returnType="[java.type]">
    <referencedElements xmi:type="process:ContractInput" xmi:id="[contractInputUUID]"
                        name="[contractInputName]" type="[CONTRACT_TYPE]">
      <mapping xmi:type="process:ContractInputMapping" xmi:id="[UUID]"/>
    </referencedElements>
  </rightOperand>
  <operator xmi:type="expression:Operator" xmi:id="[UUID]"
            type="JAVA_METHOD" expression="[setterMethod]">
    <inputTypes>[java.type]</inputTypes>
  </operator>
</operations>
```

**Example - Task Updates Boolean Field (Approval Status):**
```xml
<operations xmi:type="expression:Operation" xmi:id="uuid-op1">
  <leftOperand xmi:type="expression:Expression" xmi:id="uuid-lop1"
               name="vacationRequest" content="vacationRequest"
               type="TYPE_VARIABLE" returnType="com.company.hr.VacationRequest">
    <referencedElements xmi:type="process:BusinessObjectData" xmi:id="uuid-bd1"
                        name="vacationRequest" dataType="uuid-datatype-vr"/>
  </leftOperand>
  <rightOperand xmi:type="expression:Expression" xmi:id="uuid-rop1"
                name="Approval Decision" content="approved" interpreter="GROOVY"
                type="TYPE_READ_ONLY_SCRIPT" returnType="java.lang.Boolean">
    <referencedElements xmi:type="process:ContractInput" xmi:id="uuid-input1"
                        name="approved" type="BOOLEAN">
      <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-map1"/>
    </referencedElements>
  </rightOperand>
  <operator xmi:type="expression:Operator" xmi:id="uuid-opr1"
            type="JAVA_METHOD" expression="setApproved">
    <inputTypes>java.lang.Boolean</inputTypes>
  </operator>
</operations>
```

**Example - Task Updates String Field (Comments):**
```xml
<operations xmi:type="expression:Operation" xmi:id="uuid-op2">
  <leftOperand xmi:type="expression:Expression" xmi:id="uuid-lop2"
               name="vacationRequest" content="vacationRequest"
               type="TYPE_VARIABLE" returnType="com.company.hr.VacationRequest">
    <referencedElements xmi:type="process:BusinessObjectData" xmi:id="uuid-bd2"
                        name="vacationRequest" dataType="uuid-datatype-vr"/>
  </leftOperand>
  <rightOperand xmi:type="expression:Expression" xmi:id="uuid-rop2"
                name="Reviewer Comments" content="comments" interpreter="GROOVY"
                type="TYPE_READ_ONLY_SCRIPT" returnType="java.lang.String">
    <referencedElements xmi:type="process:ContractInput" xmi:id="uuid-input2"
                        name="comments">
      <mapping xmi:type="process:ContractInputMapping" xmi:id="uuid-map2"/>
    </referencedElements>
  </rightOperand>
  <operator xmi:type="expression:Operator" xmi:id="uuid-opr2"
            type="JAVA_METHOD" expression="setComments">
    <inputTypes>java.lang.String</inputTypes>
  </operator>
</operations>
```

**Type Mapping for Contract Inputs and Return Types:**

| Contract Input Type | returnType (Java) | ContractInput type attribute |
|---------------------|-------------------|------------------------------|
| TEXT (default)      | java.lang.String  | (omit or empty)              |
| BOOLEAN             | java.lang.Boolean | BOOLEAN                      |
| INTEGER             | java.lang.Integer | INTEGER                      |
| LONG                | java.lang.Long    | LONG                         |
| DECIMAL             | java.lang.Double  | DECIMAL                      |
| LOCALDATE           | java.time.LocalDate | LOCALDATE                  |
| LOCALDATETIME       | java.time.LocalDateTime | LOCALDATETIME          |

**Guidelines:**
- Operations are placed AFTER stepSummary and BEFORE loopCondition in task structure
- Create one operation per contract input that needs to update BDM
- Setter method name: `set + CapitalizedFieldName` (e.g., `setApproved`)
- Each referencedElements for BusinessObjectData needs a unique UUID and `dataType` attribute
- **CRITICAL**: rightOperand must ALWAYS use `TYPE_READ_ONLY_SCRIPT` with `interpreter="GROOVY"`
- **CRITICAL**: rightOperand must include `returnType` matching the Java type
- **CRITICAL**: rightOperand `name` attribute must be business-readable (e.g., "Approval Decision", "Decision CG", "Reviewer Comments")
- **CRITICAL**: ContractInput referencedElements must include a `<mapping>` element
- For BOOLEAN contract inputs, add `type="BOOLEAN"` attribute to ContractInput referencedElements
- Ensure referenced contract input UUID matches the actual contract input ID in the contract section

### 17. Add Search Indexes (Optional)

Add 5 empty search indexes:

```xml
<searchIndexes xmi:type="process:SearchIndex" xmi:id="[UUID]">
  <name xmi:type="expression:Expression" xmi:id="[UUID]" content="" returnTypeFixed="true"/>
  <value xmi:type="expression:Expression" xmi:id="[UUID]" content="" returnTypeFixed="true"/>
</searchIndexes>
<!-- Repeat 5 times -->
```

### 18. Close Pool

```xml
    </elements> <!-- End of Pool -->
```

### 19. Add Data Types

Add standard data types to MainProcess (after Pool, before closing MainProcess):

```xml
<datatypes xmi:type="process:BooleanType" xmi:id="[UUID]" name="Boolean"/>
<datatypes xmi:type="process:DateType" xmi:id="[UUID]" name="Date"/>
<datatypes xmi:type="process:IntegerType" xmi:id="[UUID]" name="Integer"/>
<datatypes xmi:type="process:LongType" xmi:id="[UUID]" name="Long"/>
<datatypes xmi:type="process:DoubleType" xmi:id="[UUID]" name="Double"/>
<datatypes xmi:type="process:StringType" xmi:id="[UUID]" name="Text"/>
<datatypes xmi:type="process:JavaType" xmi:id="[UUID]" name="Java_object"/>
<datatypes xmi:type="process:XMLType" xmi:id="[UUID]" name="XML"/>
<datatypes xmi:type="process:BusinessObjectType" xmi:id="[UUID]" name="Business_Object"/>
```

These data types are standard and must be included in every process definition.

### 20. Close MainProcess

```xml
  </process:MainProcess>
```

### 21. Add Notation Diagram

Add visual layout information. **CRITICAL**: Create a readable layout with proper spacing and horizontal flow.

**Notation Structure:**
```xml
<notation:Diagram xmi:id="[UUID_DIAGRAM]" type="Process" element="[UUID_MAINPROCESS]"
                  name="[ProcessName]" measurementUnit="Pixel">
  <children xmi:type="notation:Node" xmi:id="[UUID]" type="2007" element="[UUID_POOL]">
    <children xmi:type="notation:Node" xmi:id="[UUID]" type="5008"/>
    <children xmi:type="notation:Node" xmi:id="[UUID]" type="7001" element="[UUID_POOL]">

      <!-- For each lane -->
      <children xmi:type="notation:Node" xmi:id="[UUID]" type="3007" element="[UUID_LANE]">
        <children xmi:type="notation:Node" xmi:id="[UUID]" type="5007"/>
        <children xmi:type="notation:Node" xmi:id="[UUID]" type="7002" element="[UUID_LANE]">

          <!-- For each element in lane -->
          <children xmi:type="notation:Node" xmi:id="[UUID]" type="[TYPE]" element="[UUID_ELEMENT]">
            <styles xmi:type="notation:DescriptionStyle" xmi:id="[UUID]"/>
            <styles xmi:type="notation:FontStyle" xmi:id="[UUID]" fontName="Segoe UI"/>
            <styles xmi:type="notation:LineStyle" xmi:id="[UUID]"/>
            <styles xmi:type="notation:FillStyle" xmi:id="[UUID]"/>
            <layoutConstraint xmi:type="notation:Bounds" xmi:id="[UUID]" x="[X]" y="[Y]" width="[W]" height="[H]"/>
          </children>

        </children>
        <styles xmi:type="notation:SortingStyle" xmi:id="[UUID]"/>
        <styles xmi:type="notation:FilteringStyle" xmi:id="[UUID]"/>
        <layoutConstraint xmi:type="notation:Bounds" xmi:id="[UUID]" y="[Y_POSITION]" height="[HEIGHT]"/>
      </children>

    </children>
    <styles xmi:type="notation:SortingStyle" xmi:id="[UUID]"/>
    <styles xmi:type="notation:FilteringStyle" xmi:id="[UUID]"/>
    <layoutConstraint xmi:type="notation:Bounds" xmi:id="[UUID]" width="[WIDTH]" height="[HEIGHT]"/>
  </children>

  <!-- For each connection -->
  <edges xmi:type="notation:Connector" xmi:id="[UUID]" type="4001" element="[UUID_FLOW]"
         source="[UUID_SOURCE_NODE]" target="[UUID_TARGET_NODE]">
    <children xmi:type="notation:DecorationNode" xmi:id="[UUID]" type="6001">
      <layoutConstraint xmi:type="notation:Location" xmi:id="[UUID]" y="-10"/>
    </children>
    <styles xmi:type="notation:FontStyle" xmi:id="[UUID]" fontName="Segoe UI"/>
    <bendpoints xmi:type="notation:RelativeBendpoints" xmi:id="[UUID]" points="[0, 0, 0, 0]$[0, 0, 0, 0]"/>
    <sourceAnchor xmi:type="notation:IdentityAnchor" xmi:id="[UUID]"/>
    <targetAnchor xmi:type="notation:IdentityAnchor" xmi:id="[UUID]"/>
  </edges>

</notation:Diagram>
```

**Element Type Codes:**
- `3002` - StartEvent
- `3003` - EndEvent
- `3005` - Task
- `3006` - ServiceTask
- `3008` - Gateway (XOR, AND, Inclusive)
- `3007` - Lane (use for lane nodes)

**Layout Best Practices:**

**1. Horizontal Flow Layout:**
- **ALWAYS use left-to-right horizontal flow** for readability
- Start event on left, end events on right
- Tasks flow horizontally across the process
- Gateways positioned to branch vertically into different lanes

**2. Element Positioning:**
- **Start event**: x=50-60, y=20-30, no width/height needed (default size)
- **Tasks**: width=100, height=60
  - First task: x=150-180
  - Subsequent tasks: x += 150-200 (spacing between tasks)
  - Y position: 20-30 within lane (centered vertically)
- **Gateways**: width=40, height=40
  - Position after decision point
  - Y position: centered to align with tasks
- **End events**: no width/height needed
  - Place at end of each process path
  - Y position: centered in lane

**3. Lane Sizing and Positioning:**

**Lane Heights:**
- Use consistent lane height: 150px (recommended)
- Minimum: 100px for single-row content
- Maximum: 200px for lanes with complex elements
- **All lanes in a process should use the same height** for visual consistency

**Lane Vertical Stacking:**
- Lane 1 (initiator): y=20
- Lane 2: y=170 (= Lane1.y + Lane1.height)
- Lane 3: y=320 (= Lane2.y + Lane2.height)
- Lane 4: y=470 (= Lane3.y + Lane3.height)
- Pattern: `nextLane.y = currentLane.y + currentLane.height`

**4. Pool Sizing:**

Calculate pool dimensions based on content:
- **Width**: rightmost element x + element width + 100px margin
  - Example: Last task at x=1200, width=100 → pool width=1400px
- **Height**: sum of all lane heights + 30px top margin
  - Example: 4 lanes × 150px + 30px = 630px

**5. Horizontal Positioning Pattern:**

**Simple Linear Flow:**
```
StartEvent: x=50
Task 1:     x=180  (gap: 130)
Task 2:     x=350  (gap: 170)
Task 3:     x=520  (gap: 170)
EndEvent:   x=690  (gap: 170)
```

**Flow with Gateway Branching:**
```
StartEvent:     x=50,  Lane1
Task "Input":   x=150, Lane1
Gateway:        x=320, Lane1 (40px wide)
├─ Task "Path1": x=480, Lane2
├─ Task "Path2": x=480, Lane3
└─ Task "Path3": x=480, Lane4
```

**CRITICAL - Gateway Spacing to Prevent Label Overlap:**
- Minimum 100-150px horizontal gap between gateway and next element
- Gateway at x=320 (width=40) → Next element at x=480+ (gap = 120px minimum)
- This spacing prevents transition labels ("Oui", "Non", "Défaut") from overlapping
- For gateways with multiple outgoing flows, use 150px+ gap for readability
- Example: Gateway x=480 → End event x=640 (160px gap) ✅
- Example: Gateway x=480 → End event x=580 (100px gap) ❌ Labels overlap!

**6. Complete Example Layout (4 lanes):**

```
Pool: width=1450, height=650

Lane 1 (Initiator): y=20, height=150
  - StartEvent: x=50, y=50
  - Task "Submit": x=150, y=25, width=100, height=60

Lane 2 (Approver): y=170, height=150
  - Task "Approve": x=320, y=25, width=100, height=60
  - Gateway: x=480, y=40, width=40, height=40
  - EndEvent "Approved": x=640, y=50
  - Task "Final Check": x=800, y=25, width=100, height=60

Lane 3 (Reviewer): y=320, height=150
  - Task "Review": x=480, y=25, width=100, height=60
  - Gateway: x=640, y=40, width=40, height=40
  - EndEvent "Rejected": x=800, y=50

Lane 4 (Validator): y=470, height=150
  - Task "Validate": x=480, y=25, width=100, height=60
  - Gateway: x=640, y=40, width=40, height=40
  - EndEvent "Cancelled": x=800, y=50
```

**7. Visual Readability Checklist:**
- [ ] Horizontal left-to-right flow
- [ ] All lanes have equal height (typically 150px)
- [ ] Tasks spaced 150-200px apart horizontally
- [ ] Elements centered vertically within lanes (y=20-30 for 150px lanes)
- [ ] Gateway positioned after decision tasks
- [ ] End events clearly visible at path terminations
- [ ] Pool width accommodates rightmost element + margin
- [ ] Pool height = sum of lane heights + top margin
- [ ] No overlapping elements
- [ ] Sufficient spacing for connector arrows

**Common Layout Mistakes to Avoid:**
- ❌ Vertical flow (top-to-bottom) - hard to read with multiple lanes
- ❌ Varying lane heights - creates visual inconsistency
- ❌ Cramped spacing (< 100px between tasks) - cluttered appearance
- ❌ Inconsistent vertical positioning within lanes
- ❌ Pool too small to contain all elements
- ❌ Elements positioned outside lane boundaries

### 22. Close XMI Root

```xml
</xmi:XMI>
```

### 23. Save File

Write the complete XML to the output path (e.g., `docs/artifacts/ProcessName-1.0.proc`).

## Output

A complete Bonita Process Diagram XML file ready for validation and import into Bonita Studio.

## Validation Checklist

Before proceeding to Step 4:
- [ ] XML is well-formed
- [ ] All UUIDs are unique
- [ ] All IDREF attributes reference valid xmi:ids
- [ ] bonitaModelVersion="9"
- [ ] All namespaces declared
- [ ] All flow nodes have 3 expression elements (dynamicLabel, dynamicDescription, stepSummary)
- [ ] Pool has form mappings (formMapping with type="NONE", overviewFormMapping without type)
- [ ] Pool has contract with inputs based on BDM
- [ ] Business data has initialization script that creates BDM from pool contract inputs
- [ ] All human tasks have contracts with appropriate inputs
- [ ] All human tasks with contracts have operations to update BDM (if needed)
- [ ] All human tasks have formMapping with type="NONE"
- [ ] Every XORGateway has exactly ONE outgoing flow with isDefault="true"
- [ ] At least one actor has initiator="true"
- [ ] All elements are connected (no orphaned nodes)
- [ ] Configuration includes presales environment
- [ ] Actor mappings match actor definitions
- [ ] Business object data variables defined with defaultValue script using TYPE_READ_ONLY_SCRIPT
- [ ] Initialization script uses XML-escaped Groovy code (&#10; for newlines, &quot; for quotes)
- [ ] **All contract input references in operations use TYPE_READ_ONLY_SCRIPT with interpreter="GROOVY"**
- [ ] **All rightOperand expressions have returnType attribute**
- [ ] **All ContractInput referencedElements include <mapping> element**
- [ ] **All BusinessObjectData referencedElements include dataType attribute**
- [ ] **Visual layout uses horizontal left-to-right flow**
- [ ] **All lanes have consistent height (typically 150px)**
- [ ] **Tasks spaced 150-200px apart horizontally**
- [ ] **Elements centered vertically within lanes**
- [ ] **Pool dimensions accommodate all elements with margins**

## Notes

- Keep indentation consistent (2 spaces per level)
- Use double quotes for all XML attributes
- Empty content attributes should be `content=""`
- IDREF lists use space separation: `outgoing="uuid1 uuid2"`
- Notation coordinates are approximate - can be adjusted in Studio
- The generated process includes production-ready contracts and operations
- Forms and connectors can be added in Bonita Studio
- Reference `.claude/process-samples/` for real-world examples
- Every XOR gateway MUST have a default transition (isDefault="true")
- All contract inputs MUST have corresponding operations
- Lanes should be minimized to content size with 20px margins

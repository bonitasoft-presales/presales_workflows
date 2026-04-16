# Step 1: Extract Workflow from Analysis Document

Extract the process workflow information from the analysis document to generate the process diagram.

## Input

- Analysis document path (from skill parameters or default to most recent .adoc in `docs/out/`)

## Process

### 1. Read Analysis Document

Read the complete analysis document (AsciiDoc format).

### 2. Find Process Workflow Section

Look for sections with titles like:
- "Process Workflow"
- "Workflow"
- "Process Flow"
- "Process Description"
- "Business Process"

### 3. Extract Process Information

#### Process Name and Version
- Extract the process name from the workflow section or document title
- Default version to "1.0" if not specified
- Example: "Validation_Demande_Recrutement" version "1.0"

#### Actors and Roles
- Identify all actors mentioned in the workflow
- Extract their roles in the organization
- Determine which actor initiates the process (first actor mentioned)
- Map actor names to organization roles

Examples:
- "Manager reviews the request" → Actor: Manager
- "RH validates the form" → Actor: RH (Human Resources)
- "Employee submits request" → Actor: Employee (initiator)

#### Tasks
Identify and classify tasks:

**User Tasks** (require human intervention):
- Form filling
- Review/validation steps
- Decision making
- Approval/rejection

**Service Tasks** (automated):
- Email notifications
- Data calculations
- API calls
- Document generation

**Manual Tasks** (tracked but no form):
- External activities
- Phone calls

For each task extract:
- Name (descriptive, in imperative form)
- Type (user, service, manual)
- Actor assigned
- Description if provided

#### Decision Points (Gateways)
Identify decision points in the workflow:
- Approval/Rejection decisions (XOR gateway)
- Conditional branching
- Multiple outcomes from a task

For each gateway extract:
- Type: EXCLUSIVE (XOR), PARALLEL, INCLUSIVE
- Condition descriptions
- Possible outcomes

#### Sequence Flow
Determine the flow between elements:
- Start event → First task
- Task → Next task or gateway
- Gateway → Multiple paths with conditions
- Last task → End event

Extract conditions for flows from gateways:
- "If approved" → condition on flow
- "If rejected" → condition on flow
- "Otherwise" → default flow

### 4. Store Extracted Information

Organize the extracted information in a structured format:

```
Process:
  - Name: [ProcessName]
  - Version: [1.0]

Actors:
  - [Actor1]: initiator=true, role=[RoleName1]
  - [Actor2]: initiator=false, role=[RoleName2]
  - [Actor3]: initiator=false, role=[RoleName3]

Tasks:
  - [Task1]: type=userTask, actor=[Actor1], description=[...]
  - [Task2]: type=userTask, actor=[Actor2], description=[...]
  - [Task3]: type=automaticTask, description=[...]

Gateways:
  - [Gateway1]: type=EXCLUSIVE, description=[Decision point]

Flow:
  - Start → Task1
  - Task1 → Gateway1
  - Gateway1 → Task2 [condition: "approved"]
  - Gateway1 → Task3 [condition: "rejected"]
  - Task2 → End
  - Task3 → End
```

## Output

Structured information about the process workflow ready for XML generation:
- Process metadata (name, version)
- Actor list with roles and initiator flag
- Task list with types, actors, and descriptions
- Gateway list with types and conditions
- Sequence flow definition

## Validation

Before proceeding to the next step, verify:
- Process name is valid (no special characters except underscore)
- At least one actor is identified
- At least one task is identified
- Start and end points are clear
- Flow is complete (all elements connected)
- At least one actor has initiator=true

## Example Extraction

From analysis document:

```
## Process Workflow: Validation Demande Recrutement

The employee submits a recruitment request. The manager reviews the request
and decides whether to approve or reject it. If approved, RH validates the
final details and the request is processed. If rejected, the employee is
notified and the process ends.
```

Extracted:

```
Process:
  - Name: Validation_Demande_Recrutement
  - Version: 1.0

Actors:
  - Employee: initiator=true, role=employee
  - Manager: initiator=false, role=manager
  - RH: initiator=false, role=rh

Tasks:
  - Submit Request: type=userTask, actor=Employee
  - Review Request: type=userTask, actor=Manager
  - Validate Details: type=userTask, actor=RH
  - Notify Employee: type=automaticTask (email)

Gateways:
  - Approval Decision: type=EXCLUSIVE

Flow:
  - Start → Submit Request
  - Submit Request → Review Request
  - Review Request → Approval Decision
  - Approval Decision → Validate Details [approved]
  - Approval Decision → Notify Employee [rejected]
  - Validate Details → End
  - Notify Employee → End
```

## Notes

- Process name should follow Java naming conventions (no spaces, use underscores)
- Actor names should be descriptive and match organization roles
- Task names should be in imperative form (verb + object)
- Gateways are implicit when multiple outcomes exist from a task
- Service tasks are identified by automation keywords (notify, calculate, send)
- If no explicit actors are mentioned, create a default "Employee" actor

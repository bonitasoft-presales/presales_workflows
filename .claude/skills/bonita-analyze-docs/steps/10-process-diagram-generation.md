# Step 10: Generate Bonita Process Diagram XML File

**CRITICAL**: Generate a process diagram (.proc) file conformant to Bonita process format
**CRITICAL**: always validate file using `.claude/xsd/ProcessDefinition.xsd` xml schema


## Reference
* Read a reference process diagram from `app/diagrams/` to understand the structure (e.g., `_sampleProcessWithParameter-1.0.proc`)

## Structure
* Create a new diagram XML file in `docs/out/` directory based on the analyzed process
* use bonitaModelVersion="9"
* Use the XMI structure with proper namespaces:
  - Root: `<xmi:XMI>` with namespaces for process, notation, expression, etc.
  - `<process:MainProcess>` containing the process definition
  - `<process:Pool>` for the main process
  - `<process:Lane>` for each actor identified
  - Elements: StartEvent, EndEvent, Task (user/service), Gateway (XOR for decisions)
  - `<connections>` for SequenceFlow between elements
  - `<actors>` for each role
  - `<configurations>` for environments (Local, Qualification, etc.)
  - `<notation:Diagram>` for visual layout

## Process Elements

Based on analyzed requirements, create:

### Lanes
- Create one lane per actor identified in analysis
- Each lane contains the tasks performed by that actor

### Events
- StartEvent: where the process begins
- EndEvent: where the process ends (can be multiple end events)

### Tasks
- User Tasks: for human activities requiring forms
- Service Tasks: for automated activities (email, API calls, etc.)
- Script Tasks: for scripting operations

### Gateways
- XOR Gateway: for decision points (approval/rejection, conditions)
- Parallel Gateway: for parallel flows (if needed)

### Sequence Flows
- Connect all elements in logical order
- Add conditions on flows from XOR gateways

### Actors
- Map each actor to organization roles
- Set initiator="true" for the actor who starts the process

### Configuration
- always use `presales` configuration
- Map actors to roles in actorMappings

## ID Generation

* **Generate unique IDs** for all elements using Docker:
  ```bash
  docker run --rm python:3-alpine python3 -c "import uuid; [print(str(uuid.uuid4())) for _ in range(50)]"
  ```

## Visual Notation

* **Include visual notation** with approximate coordinates for diagram layout
* Position elements in a readable flow (left to right, top to bottom)
* Use reasonable spacing between elements

## File Naming

* Save the file as `docs/out/ProcessName-Version.proc`
* Example: `Validation_Demande_Recrutement-1.0.proc`

## Validation

* Validate the XML structure is well-formed
* Confirm file creation and provide path

## Important Note

**The generated diagram is a skeleton that can be imported into Bonita Studio and refined:**
- Add forms to user tasks
- Configure connectors on service tasks (email notifications, etc.)
- Add business data operations
- Define contracts and validation
- Add process variables
- Configure task deadlines and priorities

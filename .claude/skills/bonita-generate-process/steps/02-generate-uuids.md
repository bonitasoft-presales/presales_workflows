# Step 2: Generate UUIDs

Generate unique identifiers for all process elements using Docker Python.

## Prerequisites

- Extracted workflow information from Step 1
- Docker available for running Python

## Process

### 1. Count Required UUIDs

Calculate how many UUIDs are needed for all elements:

**Base Elements:**
- 1 for MainProcess
- 1 for Pool
- N for Lanes (one per actor)
- 1 for StartEvent
- M for EndEvents (usually 1, but can be multiple)
- P for Tasks (user tasks + service tasks)
- Q for Gateways
- R for SequenceFlows (connections between elements)
- S for Actors

**Expression Elements:**
Each flow node (StartEvent, EndEvent, Task, Gateway) needs 3 expression UUIDs:
- 1 for dynamicLabel
- 1 for dynamicDescription
- 1 for stepSummary

**Form Mappings:**
- 2 for form mappings (formMapping + targetForm)
- 2 for overview form mapping (overviewFormMapping + targetForm)

**Configuration:**
- 1 for Configuration
- 1 for ActorMappingsType
- For each actor mapping:
  - 1 for ActorMapping
  - 1 for Groups
  - 1 for Membership
  - 1 for Roles
  - 1 for Users

**Contract:**
- 1 for Contract

**Notation:**
- 1 for Diagram
- Multiple for notation elements (shapes, edges)

**Total Calculation:**
```
Base = 1 (MainProcess) + 1 (Pool) + N (Lanes) + 1 (Start) + M (Ends) + P (Tasks) + Q (Gateways) + R (Flows) + S (Actors)
Expressions = (1 (Start) + M (Ends) + P (Tasks) + Q (Gateways)) × 3
Forms = 4
Configuration = 1 (Config) + 1 (ActorMappings) + S × 5 (per actor mapping)
Contract = 1
Notation = 1 (Diagram) + (estimated visual elements)

Total = Base + Expressions + Forms + Configuration + Contract + Notation
```

**Safety margin:** Generate 20% more UUIDs than calculated to account for additional elements.

### 2. Generate UUIDs Using Docker

Use Docker to run Python and generate UUIDs:

```bash
docker run --rm python:3-alpine python3 -c "import uuid; [print(str(uuid.uuid4())) for _ in range(100)]"
```

Replace `100` with your calculated total (plus safety margin).

**Output format:**
```
a1b2c3d4-e5f6-7890-abcd-ef1234567890
b2c3d4e5-f6a7-8901-bcde-f12345678901
c3d4e5f6-a7b8-9012-cdef-123456789012
...
```

### 3. Store UUIDs

Capture all generated UUIDs in a list for use in Step 3.

**Recommended approach:** Create a mapping structure:

```
UUIDs:
  mainProcess: a1b2c3d4-e5f6-7890-abcd-ef1234567890
  pool: b2c3d4e5-f6a7-8901-bcde-f12345678901

  actors:
    Employee: c3d4e5f6-a7b8-9012-cdef-123456789012
    Manager: d4e5f6a7-b8c9-0123-def0-234567890123
    RH: e5f6a7b8-c9d0-1234-ef01-345678901234

  lanes:
    Employee: f6a7b8c9-d0e1-2345-f012-456789012345
    Manager: a7b8c9d0-e1f2-3456-0123-567890123456
    RH: b8c9d0e1-f2a3-4567-1234-678901234567

  events:
    start: c9d0e1f2-a3b4-5678-2345-789012345678
    end: d0e1f2a3-b4c5-6789-3456-890123456789

  tasks:
    SubmitRequest: e1f2a3b4-c5d6-7890-4567-901234567890
    ReviewRequest: f2a3b4c5-d6e7-8901-5678-012345678901
    ValidateDetails: a3b4c5d6-e7f8-9012-6789-123456789012
    NotifyEmployee: b4c5d6e7-f8a9-0123-7890-234567890123

  gateways:
    ApprovalDecision: c5d6e7f8-a9b0-1234-8901-345678901234

  flows:
    start_to_task1: d6e7f8a9-b0c1-2345-9012-456789012345
    task1_to_task2: e7f8a9b0-c1d2-3456-0123-567890123456
    task2_to_gateway: f8a9b0c1-d2e3-4567-1234-678901234567
    gateway_to_task3: a9b0c1d2-e3f4-5678-2345-789012345678
    gateway_to_task4: b0c1d2e3-f4a5-6789-3456-890123456789
    task3_to_end: c1d2e3f4-a5b6-7890-4567-901234567890
    task4_to_end: d2e3f4a5-b6c7-8901-5678-012345678901

  expressions:
    start_label: e3f4a5b6-c7d8-9012-6789-123456789012
    start_desc: f4a5b6c7-d8e9-0123-7890-234567890123
    start_summary: a5b6c7d8-e9f0-1234-8901-345678901234
    # ... continue for all flow nodes

  forms:
    formMapping: b6c7d8e9-f0a1-2345-9012-456789012345
    formMappingTarget: c7d8e9f0-a1b2-3456-0123-567890123456
    overviewFormMapping: d8e9f0a1-b2c3-4567-1234-678901234567
    overviewFormMappingTarget: e9f0a1b2-c3d4-5678-2345-789012345678

  configuration:
    config: f0a1b2c3-d4e5-6789-3456-890123456789
    actorMappings: a1b2c3d4-e5f6-7890-4567-901234567890
    # ... mappings for each actor

  contract: b2c3d4e5-f6a7-8901-5678-012345678901

  notation:
    diagram: c3d4e5f6-a7b8-9012-6789-123456789012
    # ... shapes and edges
```

## Output

A complete mapping of element names to UUIDs, ready for XML generation in Step 3.

## Validation

Before proceeding:
- Verify all UUIDs are unique (no duplicates)
- Verify UUID format: lowercase, 5 groups separated by hyphens
- Ensure you have UUIDs for all required elements
- Keep extra UUIDs available for any additional elements discovered during generation

## Example Command

For a process with 2 actors, 1 start, 1 end, 4 tasks, 1 gateway, 7 flows:

```bash
# Calculate:
# Base = 1 + 1 + 2 + 1 + 1 + 4 + 1 + 7 + 2 = 20
# Expressions = (1 + 1 + 4 + 1) × 3 = 21
# Forms = 4
# Configuration = 1 + 1 + (2 × 5) = 12
# Contract = 1
# Notation = 1 + ~20 = 21
# Total = 20 + 21 + 4 + 12 + 1 + 21 = 79
# With 20% margin = 95

docker run --rm python:3-alpine python3 -c "import uuid; [print(str(uuid.uuid4())) for _ in range(95)]"
```

## Notes

- UUIDs must be lowercase for XMI compatibility
- Never reuse UUIDs across different elements
- Keep UUIDs organized by element type for easier XML generation
- Generate more UUIDs than needed - better to have extras than run out
- UUID format: 8-4-4-4-12 characters (total 36 with hyphens)

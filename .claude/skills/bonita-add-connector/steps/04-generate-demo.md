# Step 4: Generate Demo Process

Create a demo process diagram that showcases the connector usage.

## Input

- Selected connector metadata
- Process name (from `--process` flag or auto-generated)
- `--no-demo` flag (skip this step if enabled)
- Connector configuration template (from docs or defaults)

## Processing

1. **Check if demo should be generated**:
   - If `--no-demo` flag: Skip this step entirely
   - Otherwise: Continue with demo generation

2. **Determine process name**:
   - If `--process` provided: Use specified name
   - Otherwise: Auto-generate as `_demo{ConnectorName}`
   - Example: `_demoEmailConnector`

3. **Check for existing demo process**:
   - Look for file: `app/diagrams/{processName}-1.0.proc`
   - If exists:
     - Warn user
     - Ask: Overwrite, Skip, or Rename
   - If user chooses rename: Append suffix like `_2`, `_3`

4. **Generate process structure**:
   - Create BPMN XML with:
     - MainProcess
     - Pool with process name
     - Lane (Employee lane)
     - Start event
     - Service task with connector
     - End event
     - Sequence flows connecting elements
     - Form mapping (type="NONE")
     - Actor mapping (Employee actor → member role)
     - Local configuration

5. **Configure connector on service task**:
   - Add connector element with full configuration:
     ```xml
     <connectors xmi:type="process:Connector"
                 xmi:id="{connector-id}"
                 name="connectorName"
                 definitionId="{connector-definition-id}"
                 event="ON_ENTER"
                 definitionVersion="{version}">
       <configuration xmi:type="connectorconfiguration:ConnectorConfiguration"
                      xmi:id="{config-id}"
                      definitionId="{connector-definition-id}"
                      version="{version}"
                      modelVersion="9">
         <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                     xmi:id="{param-id}"
                     key="paramName">
           <expression xmi:type="expression:Expression"
                       xmi:id="{expr-id}"
                       name="paramName"
                       content="paramValue"
                       returnType="java.lang.String"
                       type="TYPE_CONSTANT"/>
         </parameters>
       </configuration>
     </connectors>
     ```
   - Use default/example values from connector documentation
   - **CRITICAL**: Add `xmlns:connectorconfiguration` namespace to root `<xmi:XMI>` element
   - Add all required connector parameters based on documentation

6. **Add notation (diagram layout)**:
   - Define visual layout for BPMN elements
   - Position elements in logical flow:
     - Start: (60, 68)
     - Service task: (160, 60)
     - End: (340, 68)
   - Add sequence flow connectors

7. **Generate unique IDs**:
   - Use connector name + timestamp for ID prefixes
   - Ensure all xmi:id attributes are unique
   - Follow Bonita ID format conventions

8. **Write process file**:
   - File path: `app/diagrams/{processName}-1.0.proc`
   - Format as valid XML with proper indentation
   - Use UTF-8 encoding

9. **Validate generated process**:
   - Check XML is well-formed
   - Verify required BPMN elements exist
   - Ensure IDs are unique

## Output

- New process diagram file in `app/diagrams/`
- Confirmation with file location

## Example Output

### Demo Generated Successfully

```
[INFO] Step 4: Generating demo process...
[INFO] Process name: _demoEmailConnector
[INFO] Checking for existing demo process...
[INFO] No existing demo found, proceeding with generation

[INFO] Creating process structure...
[INFO] Adding service task: "Send Email"
[INFO] Configuring connector: bonita-connector-email
[INFO] Setting default connector parameters:
       - smtpHost: "localhost"
       - smtpPort: 25
       - from: "noreply@example.com"
       - to: "user@example.com"
       - subject: "Demo Email from Bonita"

[INFO] Adding process layout and notation...
[OK]   Process diagram generated successfully

[INFO] File created: app/diagrams/_demoEmailConnector-1.0.proc
[INFO] Process version: 1.0
[INFO] Service task: "Send Email" with email connector configured
```

### Demo Already Exists

```
[INFO] Step 4: Generating demo process...
[WARN] Demo process already exists: app/diagrams/_demoEmailConnector-1.0.proc

[PROMPT] What would you like to do?
         1. Skip (keep existing demo)
         2. Overwrite (replace with new demo)
         3. Create with different name

[USER] Selected: Create with different name

[INFO] Generating demo with suffix: _demoEmailConnector_2-1.0.proc
[OK]   Process diagram created: app/diagrams/_demoEmailConnector_2-1.0.proc
```

### Demo Skipped (--no-demo)

```
[INFO] Step 4: Generate demo process
[INFO] --no-demo flag detected, skipping demo generation
[INFO] Proceeding to validation...
```

## Process Structure Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xmi:XMI xmi:version="2.0"
         xmlns:xmi="http://www.omg.org/XMI"
         xmlns:process="http://www.bonitasoft.org/ns/bpm/process"
         xmlns:notation="http://www.eclipse.org/gmf/runtime/1.0.3/notation"
         xmlns:expression="http://www.bonitasoft.org/ns/bpm/expression">

  <process:MainProcess xmi:id="_mainProcess"
                       name="_demo{ConnectorName}"
                       version="1.0"
                       bonitaModelVersion="9">

    <elements xmi:type="process:Pool"
              xmi:id="_pool"
              name="_demo{ConnectorName}"
              documentation="Demo process showcasing {Connector Display Name}">

      <elements xmi:type="process:Lane" xmi:id="_lane" name="Employee lane" actor="_actor">

        <!-- Start Event -->
        <elements xmi:type="process:StartEvent"
                  xmi:id="_start"
                  name="Start"
                  outgoing="_flow1"/>

        <!-- Service Task with Connector -->
        <elements xmi:type="process:ServiceTask"
                  xmi:id="_serviceTask"
                  name="Use {Connector Display Name}"
                  incoming="_flow1"
                  outgoing="_flow2">

          <connectors xmi:type="process:Connector"
                      xmi:id="_connector"
                      definitionId="{connector-definition-id}"
                      event="ON_ENTER">
            <!-- Connector configuration here -->
          </connectors>
        </elements>

        <!-- End Event -->
        <elements xmi:type="process:EndEvent"
                  xmi:id="_end"
                  name="End"
                  incoming="_flow2"/>
      </elements>

      <!-- Form Mapping (NONE for demo) -->
      <formMapping xmi:type="process:FormMapping" xmi:id="_formMapping" type="NONE">
        <targetForm xmi:type="expression:Expression"
                    xmi:id="_formTarget"
                    name=""
                    content=""
                    type="FORM_REFERENCE_TYPE"
                    returnTypeFixed="true"/>
      </formMapping>

      <!-- Actor Configuration -->
      <actors xmi:type="process:Actor"
              xmi:id="_actor"
              name="Employee actor"
              initiator="true"/>

      <!-- Configuration (Local) -->
      <configurations xmi:type="configuration:Configuration"
                      xmi:id="_config"
                      name="Local"
                      version="9">
        <actorMappings>
          <actorMapping name="Employee actor">
            <roles><role>member</role></roles>
          </actorMapping>
        </actorMappings>
      </configurations>

      <!-- Contract (empty) -->
      <contract xmi:type="process:Contract" xmi:id="_contract"/>

      <!-- Sequence Flows -->
      <connections xmi:type="process:SequenceFlow"
                   xmi:id="_flow1"
                   target="_serviceTask"
                   source="_start"/>
      <connections xmi:type="process:SequenceFlow"
                   xmi:id="_flow2"
                   target="_end"
                   source="_serviceTask"/>
    </elements>

    <!-- Data Types -->
    <datatypes xmi:type="process:BooleanType" xmi:id="_boolean" name="Boolean"/>
    <datatypes xmi:type="process:StringType" xmi:id="_string" name="Text"/>
    <!-- ... other standard data types ... -->
  </process:MainProcess>

  <!-- Notation (Visual Layout) -->
  <notation:Diagram xmi:id="_diagram" type="Process" element="_mainProcess">
    <!-- Diagram layout here -->
  </notation:Diagram>
</xmi:XMI>
```

## Connector Configuration Examples

### Email Connector

**IMPORTANT**:
- Add `xmlns:connectorconfiguration="http://www.bonitasoft.org/model/connector/configuration"` to the root `<xmi:XMI>` element
- Use `returnTypeFixed="true"` instead of `type="TYPE_CONSTANT"`
- For empty parameters: use `content=""` without `name` attribute
- For list/table parameters: use `ListExpression` or `TableExpression` type

```xml
<connectors xmi:type="process:Connector"
            xmi:id="_demoEmailConnector"
            name="sendEmail"
            definitionId="email"
            event="ON_ENTER"
            definitionVersion="1.2.0">
  <configuration xmi:type="connectorconfiguration:ConnectorConfiguration"
                 xmi:id="_demoEmailConnectorConfig"
                 definitionId="email"
                 version="1.2.0"
                 modelVersion="9">
    <!-- SMTP Server Configuration -->
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param1"
                key="smtpHost">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr1"
                  name="localhost"
                  content="localhost"
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param2"
                key="smtpPort">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr2"
                  name="25"
                  content="25"
                  returnType="java.lang.Integer"
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param3"
                key="sslSupport">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr3"
                  name="false"
                  content="false"
                  returnType="java.lang.Boolean"
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param4"
                key="starttlsSupport">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr4"
                  name="false"
                  content="false"
                  returnType="java.lang.Boolean"
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param5"
                key="trustCertificate">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr5"
                  name="false"
                  content="false"
                  returnType="java.lang.Boolean"
                  returnTypeFixed="true"/>
    </parameters>

    <!-- Authentication (optional) -->
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param6"
                key="userName">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr6"
                  content=""
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param7"
                key="password">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr7"
                  content=""
                  returnTypeFixed="true"/>
    </parameters>

    <!-- Email Details -->
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param8"
                key="from">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr8"
                  name="noreply@example.com"
                  content="noreply@example.com"
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param9"
                key="returnPath">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr9"
                  content=""
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param10"
                key="to">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr10"
                  name="user@example.com"
                  content="user@example.com"
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param11"
                key="cc">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr11"
                  content=""
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param12"
                key="bcc">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr12"
                  content=""
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param13"
                key="subject">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr13"
                  name="Demo Email"
                  content="Demo Email"
                  returnTypeFixed="true"/>
    </parameters>

    <!-- Message Content -->
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param14"
                key="html">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr14"
                  name="false"
                  content="false"
                  returnType="java.lang.Boolean"
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param15"
                key="message">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr15"
                  name="Demo message"
                  content="This is a demo email from Bonita connector"
                  returnTypeFixed="true"/>
    </parameters>

    <!-- Advanced Options -->
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param16"
                key="charset">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr16"
                  name="UTF-8"
                  content="UTF-8"
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param17"
                key="replyTo">
      <expression xmi:type="expression:Expression"
                  xmi:id="_expr17"
                  content=""
                  returnTypeFixed="true"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param18"
                key="headers">
      <expression xmi:type="expression:TableExpression"
                  xmi:id="_expr18"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_param19"
                key="attachments">
      <expression xmi:type="expression:ListExpression"
                  xmi:id="_expr19"/>
    </parameters>
  </configuration>
</connectors>
```

**Key Differences from Incorrect Format:**
1. ✅ Use `returnTypeFixed="true"` NOT `type="TYPE_CONSTANT"`
2. ✅ Empty parameters: `content=""` without `name` attribute
3. ✅ All 19 parameters included (not just 6)
4. ✅ `definitionVersion="1.2.0"` (actual Bonita version)
5. ✅ List/Table types: `ListExpression` and `TableExpression`
6. ✅ Boolean/Integer types: include `returnType` attribute

### Database Connector

```xml
<connectors xmi:type="process:Connector"
            xmi:id="_demoDatabaseConnector"
            name="executeQuery"
            definitionId="database-jdbc-query"
            event="ON_ENTER"
            definitionVersion="2.1.0">
  <configuration xmi:type="connectorconfiguration:ConnectorConfiguration"
                 xmi:id="_demoDatabaseConnectorConfig"
                 definitionId="database-jdbc-query"
                 version="2.1.0"
                 modelVersion="9">
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_demoDatabaseParamDriver"
                key="driver">
      <expression xmi:type="expression:Expression"
                  xmi:id="_demoDatabaseParamDriverExpr"
                  name="driver"
                  content="org.h2.Driver"
                  returnType="java.lang.String"
                  type="TYPE_CONSTANT"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_demoDatabaseParamUrl"
                key="url">
      <expression xmi:type="expression:Expression"
                  xmi:id="_demoDatabaseParamUrlExpr"
                  name="url"
                  content="jdbc:h2:mem:testdb"
                  returnType="java.lang.String"
                  type="TYPE_CONSTANT"/>
    </parameters>
    <parameters xmi:type="connectorconfiguration:ConnectorParameter"
                xmi:id="_demoDatabaseParamQuery"
                key="query">
      <expression xmi:type="expression:Expression"
                  xmi:id="_demoDatabaseParamQueryExpr"
                  name="query"
                  content="SELECT * FROM users LIMIT 10"
                  returnType="java.lang.String"
                  type="TYPE_CONSTANT"/>
    </parameters>
  </configuration>
</connectors>
```

## Error Handling

### Cannot Create File

```
[ERROR] Failed to create demo process file
[ERROR] Path: app/diagrams/_demoEmailConnector-1.0.proc
[ERROR] Reason: Permission denied

Please check:
  - Directory app/diagrams/ exists and is writable
  - You have permission to create files
```

### Invalid Process XML

```
[ERROR] Generated process XML is not valid
[ERROR] Validation failed at: <connectors> element

This is a bug in the skill. The demo process was not created.
Please report this issue.
```

## CRITICAL: Connector Configuration Format Rules

⚠️ **These rules MUST be followed exactly or the connector will not work:**

1. **Expression Type Attribute**:
   - ✅ CORRECT: `returnTypeFixed="true"`
   - ❌ WRONG: `type="TYPE_CONSTANT"`
   - Exception: Use `type="TYPE_PATTERN"` for pattern expressions (like HTML message)

2. **Empty Parameters**:
   - ✅ CORRECT: `<expression content="" returnTypeFixed="true"/>`
   - ❌ WRONG: `<expression name="" content="" returnTypeFixed="true"/>`
   - Rule: No `name` attribute when content is empty

3. **Non-Empty Parameters**:
   - ✅ CORRECT: `<expression name="value" content="value" returnTypeFixed="true"/>`
   - Both `name` and `content` should have the same value

4. **Data Types**:
   - String: `returnTypeFixed="true"` (no returnType attribute)
   - Integer: `returnType="java.lang.Integer" returnTypeFixed="true"`
   - Boolean: `returnType="java.lang.Boolean" returnTypeFixed="true"`

5. **Collection Types**:
   - Lists: `<expression xmi:type="expression:ListExpression"/>`
   - Tables: `<expression xmi:type="expression:TableExpression"/>`
   - No content or name attributes needed

6. **Definition Version**:
   - Use actual Bonita connector version (e.g., "1.2.0")
   - Match both `definitionVersion` and `version` attributes

## Validation Checks

1. **XML well-formed**: Parse with XML parser
2. **Required BPMN elements present**: Pool, Lane, Start, Task, End
3. **Unique IDs**: All xmi:id values are unique
4. **Valid connector reference**: definitionId matches connector
5. **File naming**: Matches pattern `{name}-{version}.proc`
6. **Connector format**: Follows the rules above exactly
7. **All required parameters**: Include ALL connector parameters (not just core ones)

## Tips

- Use the `_sampleProcessWithParameter-1.0.proc` as a reference template
- Keep demo processes simple (one service task only)
- Add helpful comments in the process documentation
- Set realistic default values for connector parameters
- Test generated process can be opened in Bonita Studio

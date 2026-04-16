# Step 11: Generate Bonita Profile XML File

**CRITICAL**: Generate a profile XML file conformant to Bonita profile format
**CRITICAL**: always validate file using `.claude/xsd/profiles.xsd` xml schema

## Reference
* Read the reference profile format from `app/profiles/default_profile.xml` to understand the structure

## Structure
* Create a new profile XML file in `docs/out/` directory based on analyzed actors and access requirements
* Use the XML structure with proper namespace:
  - Root element: `<profiles:profiles xmlns:profiles="http://documentation.bonitasoft.com/profile-xml-schema/1.0">`
  - Contains multiple `<profile>` elements

## Create Profile Elements

Create one profile per main actor type or access level.

Each profile should have:
* isDefault="false" (unless it's meant to be a default profile)
* name: descriptive name (e.g., "Demandeur", "Valideur RH", "Valideur CG", "Admin RH")
* description: clear description of who this profile is for
* profileMapping with: users, groups, memberships, roles

## Profile Mapping

- Map profiles to appropriate roles created in organization
- Can map to specific users, groups, memberships, or roles
- Typically map to roles for flexibility

## Example

```xml
<profiles:profiles xmlns:profiles="http://documentation.bonitasoft.com/profile-xml-schema/1.0">
  <profile isDefault="false" name="Demandeur">
    <description>Profile pour les demandeurs (Directions et Assistantes de direction)</description>
    <profileMapping>
      <users/>
      <groups/>
      <memberships/>
      <roles>
        <role>demandeur</role>
      </roles>
    </profileMapping>
  </profile>
  <profile isDefault="false" name="Valideur RH">
    <description>Profile pour les validateurs du service RH</description>
    <profileMapping>
      <users/>
      <groups/>
      <memberships/>
      <roles>
        <role>valideur_rh</role>
        <role>admin_rh</role>
      </roles>
    </profileMapping>
  </profile>
  <!-- More profiles... -->
</profiles:profiles>
```

## Include Default Bonita Profiles (if needed)

- Can include standard Bonita profiles: "User", "Administrator", "Process manager"
- Set isDefault="true" for these
- Map to role "member" or appropriate organizational roles

## Finalization

* Save the file as `docs/out/profile.xml`
* Validate the XML structure is well-formed
* Confirm file creation and provide path

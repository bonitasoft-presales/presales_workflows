# Step 7: Generate Bonita Organization XML File

**CRITICAL**: Generate an organization XML file conformant to Bonita organization format
**CRITICAL**: always validate file using `.claude/xsd/organization.xsd` xml schema 

## Reference
* Read the reference organization format from `app/organizations/ACME.xml` to understand the structure

## Structure
* Create a new organization XML file in `docs/out/` directory based on analyzed actors and roles
* Use the XML structure with proper namespace:
  - Root element: `<organization:Organization xmlns:organization="http://documentation.bonitasoft.com/organization-xml-schema/1.1">`
  - Contains: users, roles, groups, memberships sections

## Create Users Section
- For each actor/role identified, create representative test users
- At minimum, create 1-2 users per actor type (e.g., 2 RH users, 1 Controle Gestion user, 1 Budget user, 2-3 Direction users)
- User structure:
  * userName: lowercase, dot-separated (e.g., "jean.dupont")
  * firstName, lastName, title (Mr/Mrs), jobTitle
  * manager: userName of the manager (if applicable)
  * professionalData: email, phoneNumber (optional: faxNumber, building, address, zipCode, city, state, country)
  * metaDatas (optional: Skype ID, Twitter, Facebook)
  * enabled: true
  * password: encrypted="false" with value "bpm" (for demo/test purposes)

## Create Roles Section
- Create roles based on the process actors identified (e.g., DEMANDEUR, VALIDEUR_RH, VALIDEUR_CG, VALIDEUR_BUDGET, ADMIN_RH)
- Each role should have: name, displayName, description

## Create Groups Section
- Create groups based on organizational structure identified
- Each group should have: name, displayName, description, parentPath (if nested)
- Example hierarchy:
  * Root group (e.g., "cnaf")
  * Directions group with parentPath (e.g., "directions" under "/cnaf")
  * RH group (e.g., "rh" under "/cnaf")
  * Finance group (e.g., "finance" under "/cnaf")
  * Control Gestion as subgroup (e.g., "control_gestion" under "/cnaf/finance")
  * Budget as subgroup (e.g., "budget" under "/cnaf/finance")

## Create Memberships Section
- Link each user to appropriate role(s) and group(s)
- Membership structure: userName, roleName, groupName, groupParentPath
- Ensure each user has at least one membership

## Example

```xml
<organization:Organization xmlns:organization="http://documentation.bonitasoft.com/organization-xml-schema/1.1">
  <users>
    <user userName="marie.martin">
      <firstName>Marie</firstName>
      <lastName>Martin</lastName>
      <title>Mrs</title>
      <jobTitle>Responsable RH</jobTitle>
      <professionalData>
        <email>marie.martin@cnaf.fr</email>
        <phoneNumber>01 23 45 67 89</phoneNumber>
      </professionalData>
      <metaDatas/>
      <enabled>true</enabled>
      <password encrypted="false">bpm</password>
    </user>
    <!-- More users... -->
  </users>
  <roles>
    <role name="valideur_rh">
      <displayName>Valideur RH</displayName>
      <description>Validateur du service Ressources Humaines</description>
    </role>
    <!-- More roles... -->
  </roles>
  <groups>
    <group name="cnaf">
      <displayName>CNAF</displayName>
      <description>Caisse Nationale des Allocations Familiales</description>
    </group>
    <group name="rh" parentPath="/cnaf">
      <displayName>Ressources Humaines</displayName>
      <description>Service RH de la CNAF</description>
    </group>
    <!-- More groups... -->
  </groups>
  <memberships>
    <membership>
      <userName>marie.martin</userName>
      <roleName>valideur_rh</roleName>
      <groupName>rh</groupName>
      <groupParentPath>/cnaf</groupParentPath>
    </membership>
    <!-- More memberships... -->
  </memberships>
</organization:Organization>
```

## Finalization
* Save the file as `docs/out/organization.xml`
* Validate the XML structure is well-formed
* Confirm file creation and provide path

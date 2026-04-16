# Step 12: Provide Summary

After creating all output files, provide a brief summary to the user:

## Statistics to Report

- Number of processes identified
- Number of BDM entities identified
- Number of actors identified
- Number of integration requirements identified
- Number of available connectors found (presales + community)
- Number of UI Builder pages recommended
- Number of users created in organization
- Number of roles created in organization
- Number of groups created in organization
- Number of profiles created
- Number of tasks in process diagram

## Location of Generated Files

* Analysis document (.adoc) - includes connector recommendations
* BOM file (bom.xml)
* Organization file (organization.xml)
* Profile file (profile.xml)
* Process diagram (.proc) - ready to import
* UI Builder specifications (.adoc) - optional separate file

## Next Steps for Implementation

1. **Import process diagram into Bonita Studio**
   - File → Import → BOS Archive
   - Select the .proc file

2. **Import BOM into Bonita Studio**
   - Development → Business Data Model → Define
   - Click Import → Select bom.xml

3. **Import organization into Bonita Studio**
   - Organization → Manage
   - Click Import → Select organization.xml
   - Publish the organization

4. **Review connector recommendations**
   - Check the analysis document for connector suggestions
   - Install needed connectors

5. **Refine process diagram**
   - Add forms to user tasks
   - Configure connectors on service tasks (email notifications, etc.)
   - Add business data operations
   - Define contracts and validation
   - Add process variables

6. **Develop UI Builder pages**
   - Follow UI Builder specifications document
   - Create pages one by one
   - Test with real data

7. **Deploy with bonita-la-deployer**
   - Package the application
   - Deploy to target environment

## Summary Format

Present a clear, bulleted summary that gives the user confidence in what was generated and what their next steps should be.

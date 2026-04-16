# Step 8: Identify and Recommend Connectors

**IMPORTANT**: If integration requirements are identified in Step 2 (external systems, APIs, email, databases, file operations), search for available connectors

## Search for Connectors

Use the WebFetch or WebSearch tool to query GitHub repositories:
- **Presales Connectors**: https://github.com/orgs/bonitasoft-presales/repositories?q=connector
- **Open Source Connectors**: https://github.com/orgs/Bonitasoft-Community/repositories?q=connector

## Match Requirements to Connectors

For each integration requirement identified:
- Search for matching connectors (e.g., "email" → look for email connectors, "REST API" → look for REST connectors, "database" → look for database connectors)
- List available connectors with:
  * Connector name
  * Repository URL
  * Description
  * Which integration requirement it addresses
- Categorize as "Presales Connector" or "Open Source Community Connector"

## Add to AsciiDoc

Add a section to the .adoc file called "== Recommended Connectors" with:

### Subsection: Integration Requirements Summary
- List all integrations needed

### Subsection: Available Presales Connectors
Table format:
* Connector Name | Repository URL | Purpose | Addresses Requirement

### Subsection: Available Community Connectors
Similar table format

### Subsection: Connector Installation Guide
Step-by-step instructions:
* How to clone the repository
* How to build the connector (Maven commands)
* How to deploy to Bonita Studio
* How to configure in process

### Subsection: Custom Development Needed
- List requirements without available connectors

### Context-Specific Guidance
- For each connector, explain *what it could help with* and *how to use it* in the context of this project

## Alternatives

If no suitable connector is found for a requirement, suggest alternatives:
- Build a custom connector
- Use REST API extension instead
- Use Groovy scripts with Java libraries
- Use external service task

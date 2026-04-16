# XML schema list 


## Global Directives

**IMPORTANT GLOBAL DIRECTIVE**: If you need any tooling (python3, xmllint, jq, etc.), use a Docker version to run the tool instead of relying on local installation. Example: `docker run --rm python:3 python3 -c "import uuid; print(uuid.uuid4())"` or `docker run --rm cytopia/xmllint xmllint --version`.

## list

actor mapping: 
https://raw.githubusercontent.com/bonitasoft/bonita-engine/185f8e2373fdf2285941e7319b87a4b26d905050/bpm/bonita-core/bonita-process-engine/src/main/resources/actorMapping.xsd

process
https://raw.githubusercontent.com/bonitasoft/bonita-artifacts-model/77358e87b9b27f98a7bbc84fbf329bdc65ccef71/process-definition-model/src/main/resources/ProcessDefinition.xsd
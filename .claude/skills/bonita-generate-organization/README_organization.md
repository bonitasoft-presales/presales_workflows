= instructions for Organization generation

**CRITICAL** : read and apply conventions located in `context-ia` folder and sub folder

== additions

* create sample users, with french names 
* create a `organization.adoc` file that resume organization in a readable language for business user 


=== file name

**CRITICAL** final doc must be named `CNAF_organization.xml`and put in folder `app/organizations`


=== Rule for bonita studio

**Always** add a user `Walter Bates`, with admin access

=== Rule for top level membership

**CRITICAL** : top level membership `groupParentPath` attribute must be empty

wrong example: 
```
        <membership>
            <userName>jean.martin</userName>
            <roleName>member</roleName>
            <groupName>cnaf</groupName>
            <groupParentPath>/</groupParentPath>
        </membership>
```

valid example:
```
        <membership>
            <userName>jean.martin</userName>
            <roleName>member</roleName>
            <groupName>cnaf</groupName>
            <groupParentPath></groupParentPath>
        </membership>
```

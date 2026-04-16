= instructions for Profile generation

**CRITICAL** : read and apply conventions located in `context-ia` folder and sub folder

== additions

=== file name

final doc must be named `CNAF_profiles.xml`and put in folder `app/profiles`

=== CRITICAL: Default profiles exclusion

**IMPORTANT**: Default Bonita profiles (User, Administrator, Process manager) already exist in `app/profiles/default_profile.xml` and MUST NOT be included in CNAF_profiles.xml.

**Only generate CUSTOM application-specific profiles** in CNAF_profiles.xml:
- Initiateur
- Valideur_RH
- Valideur_Controle_Gestion
- Valideur_Budget
- Lecteur
- Administrateur_Systeme
- etc.

**Exclude these default profiles:**
- User (isDefault="true")
- Administrator (isDefault="true")
- Process manager (isDefault="true")

These default profiles are deployed separately from default_profile.xml.

=== Rule for bonita studio

**Always** add a user `Walter Bates`, with admin access in the Administrator profile mapping (add to users list)


# Step 9: Analyze and Recommend UI Builder Application Structure

**IMPORTANT**: The project will use **Bonita UI Builder** (not UI Designer) for creating the user application

## Overview

Based on the analyzed requirements, identify and document the application structure needed. Add a section to the .adoc file called "== Application UI Builder - Pages et Menus"

## Subsection: Technology Choice

- Clarify that the application will use **Bonita UI Builder** (modern, component-based)
- UI Builder uses: React-based pages, modern widgets, responsive design
- NOT using UI Designer (legacy technology)

## Subsection: Pages Required

For each page, specify:
- Page name
- Purpose/description
- Target users (which profiles can access)
- Main content/sections
- Key widgets needed (tables, forms, charts, filters, etc.)
- Data sources (BDM queries, APIs)
- Actions available (buttons, links)

### Typical Pages (adapt to project context)

1. **Page Accueil / Dashboard**
   - Purpose: Landing page with overview and quick access
   - Users: All profiles
   - Content: KPI cards (requests in progress, pending validations, etc.), quick links
   - Widgets: Cards, Charts, Action buttons
   - Data: Aggregated statistics from BDM queries

2. **Page Nouvelle Demande**
   - Purpose: Create new request
   - Users: Requesters/Initiators
   - Content: Form with all required fields
   - Widgets: Text inputs, dropdowns, textarea, date picker
   - Data: Create BDM entity
   - Actions: Submit, Save draft, Cancel

3. **Page Mes Demandes**
   - Purpose: List user's own requests
   - Users: Requesters
   - Content: Table of requests filtered by current user
   - Widgets: Data table with filters, status badges, action buttons
   - Data: BDM queries filtered by creator
   - Actions: View detail, Duplicate, Cancel request

4. **Page Workflow / Validations en Attente**
   - Purpose: List pending validations
   - Users: Validators
   - Content: Table of requests awaiting validation by user's role
   - Widgets: Data table with filters by status, date
   - Data: BDM queries filtered by status
   - Actions: View detail and validate/reject

5. **Page Détail Demande**
   - Purpose: View/validate a specific request
   - Users: All profiles (read-only for some)
   - Content: Full request details, validation history, action buttons
   - Widgets: Read-only fields, history timeline, validation form (if validator)
   - Data: BDM queries, history
   - Actions: Validate, Reject (with comment), Return to list

6. **Page Recherche / Historique**
   - Purpose: Search and view all requests
   - Users: Admins, Managers
   - Content: Advanced search form + results table
   - Widgets: Search filters, data table, export button
   - Data: Custom queries with filters
   - Actions: View detail, Export to Excel/CSV

7. **Page Administration** (optional)
   - Purpose: Manage application settings
   - Users: Admin only
   - Content: Tabs for different admin functions
   - Widgets: Forms, tables for CRUD operations
   - Data: Manage reference data
   - Actions: Add/edit/delete

8. **Page Rapports / KPI**
   - Purpose: Statistics and reporting dashboard
   - Users: Management
   - Content: Charts, graphs, KPI cards
   - Widgets: Charts (pie, bar, line), KPI cards, date range selector
   - Data: Aggregated queries
   - Actions: Filter by date range, export reports

## Subsection: Application Menu Structure

Define menu structure for each profile (adapt to project):

**Menu pour Demandeurs:**
- 🏠 Accueil
- ➕ Nouvelle Demande
- 📋 Mes Demandes
- 🔍 Rechercher (optional, limited scope)

**Menu pour Valideurs:**
- 🏠 Accueil
- ✅ Validations en Attente
- 📋 Toutes les Demandes
- 🔍 Recherche Avancée
- 📊 Rapports
- ⚙️ Administration (if admin role)

## Subsection: UI Builder Widgets and Components

List of Bonita UI Builder components needed:
- *Form widgets:* Text input, Textarea, Select dropdown, Date picker, File upload, Checkbox, Radio buttons
- *Display widgets:* Data table, Cards, Badges (status), Timeline (history), KPI cards, Charts (bar, pie, line)
- *Action widgets:* Buttons (primary, secondary, danger), Links, Modal dialogs
- *Layout widgets:* Container, Grid, Tabs, Panels, Divider
- *Navigation:* Breadcrumbs, Pagination

## Subsection: Page Layouts

Recommend using:
- Existing project layout: `BonitaPresalesHorizontalLayoutV9` (from app/web_page)
- Custom CSS classes from `presalesCSS.scss`
- Responsive design for desktop and tablet

## Subsection: Data Integration

Each page will integrate with:
- *BDM queries* for data retrieval (findByX, findByY, etc.)
- *Process APIs* for starting instances and executing tasks
- *Custom REST APIs* if complex operations needed

## Subsection: Navigation Flow

Document typical user journeys:
- *Demandeur flow:* Accueil → Nouvelle Demande → (submit) → Mes Demandes → Détail
- *Valideur flow:* Accueil → Validations en Attente → Détail Demande → (validate) → Validations en Attente
- *Admin flow:* Accueil → Recherche → Export → Rapports

## Subsection: Next Steps for UI Development

- Create Living Application descriptor (XML)
- Create pages in UI Builder (one by one)
- Map pages to application menu
- Define page visibility by profile
- Test with real data

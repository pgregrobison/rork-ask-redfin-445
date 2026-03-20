# Standardize all combined toolbar buttons to 44×44pt with 4pt gaps

**What's changing**

Update all grouped toolbar buttons across the app to match the list/filter button pattern: each action gets a 44×44pt touch area with a 4pt gap between actions.

**Affected areas**

- **Find screen → trailing toolbar (sort + profile):** Gap is currently 8pt → reduce to 4pt. Add explicit 44×44pt tap targets to both the sort menu and profile button.
- **Listing detail screen → trailing toolbar (share + save):** Gap is currently 16pt → reduce to 4pt. Add explicit 44×44pt tap targets to both the share and heart buttons.

**Already correct (no changes needed)**

- Find screen → leading toolbar (list + filter): Already 44×44pt with 4pt gap
- Map controls (layers, draw, locate): Already 44×44pt per button in a vertical glass stack

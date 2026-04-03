# Standardize toolbars to match the Detail Page pattern

**What's wrong now:**
The Find tab stuffs multiple trailing buttons (sort, profile) into a single toolbar slot with hand-tuned spacing. Every other screen (Detail Page, For You, Saved, My Home) uses the native pattern — one toolbar item per action — and the system handles spacing automatically.

**What changes:**
- **Find tab trailing toolbar** — Split the sort button and profile button into their own individual toolbar items (just like the Detail Page has separate items for heart and share). Remove the manual `HStack` and `spacing: 12` wrapper entirely.
- No visual change to other screens — they already follow the correct pattern.

This is a one-file change in the Find view. The system toolbar spacing will be consistent across the entire app.
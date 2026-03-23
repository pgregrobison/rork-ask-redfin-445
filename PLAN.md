# Use native Apple Toolbars for consistent navigation actions

**Problem:** On the map view, the single profile action in the top-right has too much horizontal padding because it's wrapped in an `HStack` designed for two items. Switching to list view (which shows both sort and profile) looks correct. This inconsistency stems from manually grouping toolbar actions in `HStack` containers instead of using separate native `ToolbarItem` placements.

**What changes:**

- **Find screen (map/list):** Break the grouped `HStack` toolbar items into individual `ToolbarItem` entries. Each action (map/list toggle, filters, sort, profile) gets its own `ToolbarItem`. The sort button conditionally appears only in list mode — native toolbar handles spacing automatically whether there's one or two trailing items.
- **Listing detail screen:** Same treatment — share and heart actions become separate `ToolbarItem` entries instead of being grouped in an `HStack`.
- **Ask Redfin sheet:** Already uses individual `ToolbarItem` entries — no changes needed.
- **For You, Saved, My Home screens:** These use `navigationTitle` with large display mode and have no custom trailing actions currently — a profile action will be added as a single `ToolbarItem` for consistency across all tabs.

**What stays the same:**

- All icon sizes remain at 17pt with 44×44pt tap areas
- The glass-styled location pill on the map stays as the principal item
- The map's floating action buttons (layers, draw, location) are unaffected — they're overlay buttons, not toolbar items
- Tab bar and all other UI unchanged


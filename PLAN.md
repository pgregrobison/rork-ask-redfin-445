# Add "Search Behavior" option to Debug Panel with Map Focus mode

## Features

- **New Debug Setting: Search Behavior** — A new section in the debug panel with two options:
  - **Default** (current behavior) — Chat opens as a full sheet, "Show on map" button dismisses chat and fits pins
  - **Map Focus** — When searching for homes from the Find tab's map view, the chat sheet drops to half-height so the map and chat coexist on screen

- **Map Focus behavior** — When enabled and the user is on the Find tab (map view):
  1. Chat opens normally as a full-height sheet via the FAB
  2. When a search returns home results, the sheet animates down to half-height
  3. The map smoothly animates to fit all returned pins in the visible upper half of the screen
  4. The user can swipe the sheet back up to full height (standard sheet behavior, map dims behind)
  5. If the user dismisses the sheet entirely, pins remain on the map for browsing
  6. On any other tab or in list view, chat behaves as it does today regardless of this setting

## Design

- Debug panel gets a third section titled **"Search Behavior"** matching the existing row style (title, subtitle, checkmark)
- "Default" subtitle: *"Full sheet chat, manual show on map"*
- "Map Focus" subtitle: *"Chat drops to half-sheet on search, pins auto-fit"*
- The half-sheet uses the standard system `.medium` and `.large` detents — no custom heights
- Sheet transitions use smooth spring animation

## How It Works (User Perspective)

1. Open the debug panel from the profile action on My Home
2. Select "Map Focus" under the new Search Behavior section
3. Go to the Find tab in map view, tap the Ask Redfin FAB
4. Chat opens full-screen as usual — type "Show me 3 bed homes in Seattle"
5. When results appear with listing cards, the sheet slides down to half-height
6. The map behind animates to nicely frame all the returned pins in the upper portion
7. You can scroll through the chat, tap a listing card, or swipe up for the full chat
8. Dismiss the sheet and the pins stay on the map for you to explore
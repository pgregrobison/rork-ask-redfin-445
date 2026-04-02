# Debug Panel with Transition Picker

## Features

- **Debug Panel** accessible from a visible button at the bottom of the "My Home" screen
- Opens as a native sheet (consistent with existing filter sheets)
- **Transition Picker**: Choose how tapping a home card navigates to the detail page
  - **Native Push** — the current standard navigation push (default)
  - **Fluid Grow** — the card visually expands/grows into the detail page using matched geometry animation
- Selected transition is saved and persists across app launches

## Design

- A subtle "Debug" button at the bottom of My Home, styled with a wrench/ant icon and secondary text so it's clearly a dev tool
- The sheet uses a clean grouped list layout with labeled sections
- Each debug option is a distinct section — starting with "Card Transition"
- The transition picker uses a segmented-style row with pill options (Native Push / Fluid Grow)
- Designed to be easily extensible — adding new debug toggles/pickers is straightforward

## How It Works

- **Native Push**: Tapping a card does `navigationPath.append(listing)` as it does today
- **Fluid Grow**: Tapping a card triggers a matched geometry transition — the card grows into a full-screen detail view overlaid on top, with a spring animation. Back navigation reverses the effect. The standard NavigationStack push is bypassed for this mode.
- A shared `DebugSettings` object (saved to UserDefaults) is injected into the environment so all views can read the current transition preference

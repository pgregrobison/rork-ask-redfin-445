# Liquid Glass Location Menu on Find Page

## Features

- **Unified header pill** on both Map and List views showing the location name + "# homes" as subtitle text
- **Tappable location pill** that expands into a liquid glass overlay panel using a morph transition
- **Location search** inside the expanded menu — shows the current location in a text field; type to see location suggestions, tap a suggestion to move the map
- **Filter action** inside the menu — tapping it opens a separate filter sheet
- **Save Search action** inside the menu with a bookmark icon
- **Filter button removed** from the top toolbar — it now lives inside the expanded menu
- **Sort menu removed** from the list view toolbar — the sort option moves into the expanded menu as well

## Design

- The location pill in the nav bar shows **location name** (bold) and **"X homes"** (caption, secondary) stacked vertically, wrapped in a glass capsule — identical on both map and list views
- Tapping the pill triggers a **liquid glass morph animation** (iOS 26) — the pill smoothly expands into a larger rounded-rect panel below the nav bar
- The expanded panel contains:
  1. A search field pre-filled with the current location, with a magnifying glass icon
  2. As you type, a list of location suggestions appears (using Apple's `MKLocalSearchCompleter`)
  3. A row of menu actions: **Filter** (slider icon), **Save Search** (bookmark icon)
- Tapping outside the panel or tapping the pill again closes it with a reverse morph animation
- On iOS 18 (pre-26), the panel uses `.ultraThinMaterial` as a fallback instead of liquid glass
- The filter sheet (opened from the menu) has placeholder filter categories (beds, price, property type) for now

## Pages / Screens

- **Find page (Map mode)** — unified glass pill header with location + home count; tapping pill opens the glass menu overlay; map action buttons remain on the right side of the map
- **Find page (List mode)** — same unified glass pill header; sort option moves into the expanded menu; list of homes below
- **Location menu overlay** — the expanded glass panel with search field, suggestions list, and action buttons
- **Filter sheet** — a half-height sheet with placeholder filter options (beds, baths, price range, property type)
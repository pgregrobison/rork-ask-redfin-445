# Add Price, Bed & Bath Filters to Location Menu

**Features**
- Tapping the location pill opens the menu with quick filters built right in
- **Location input** stays at the top of the menu (as it is now)
- **Price filter** — two side-by-side dropdown menus for Min and Max price (e.g. No Min / $500K / $750K / $1M … No Max)
- **Beds filter** — horizontal segmented pills: Any, 1+, 2+, 3+, 4+, 5+
- **Baths filter** — horizontal segmented pills: Any, 1+, 2+, 3+, 4+
- Filters apply immediately as you change them — listings update live on both map and list
- Bottom row has two equal-width buttons: **Filter** (opens the full filter sheet) and **Save Search**, each filling half the row with a centered icon + label
- Filter state persists while browsing (resets on app relaunch)

**Design**
- Filters sit inside the existing expanding pill menu, below the location search field
- Each filter section has a subtle label (Price, Beds, Baths) in secondary text
- Price dropdowns use the native `Menu` picker style, styled as compact capsules side by side
- Bed/bath segmented pills are tappable capsules in a horizontal row, with the selected option highlighted
- Thin dividers separate each section for visual clarity
- The two bottom action buttons share the row equally, with rounded background and icon + text centered

**Layout (top to bottom inside the menu)**
1. Location search input (existing)
2. Divider
3. Price row — "Price" label, then Min / Max dropdown menus
4. Beds row — "Beds" label, then segmented pills
5. Baths row — "Baths" label, then segmented pills
6. Divider
7. Two equal-width action buttons: Filter (slider icon) | Save Search (bookmark icon)
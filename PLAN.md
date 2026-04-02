# Move Find toolbar to native navigation bar

**What changes**

Move all the custom floating toolbar elements on the Find screen into the native navigation bar so zoom transitions animate correctly (fade in place, no fly-in from the side).

**Layout in the native toolbar:**
- **Left side**: List/map toggle button (glass style)
- **Center (principal)**: Collapsed pill showing the location name and home count — tapping it opens the expanded menu
- **Right side**: Sort button (only visible in list mode) and profile button (glass style)

**Expanded location menu:**
- When the center pill is tapped, the expanded menu (search, price, beds, baths, filter/save actions) appears as a content overlay anchored to the top of the screen, just below the navigation bar — same content and animation as today
- A background dimming layer still dismisses the menu on tap
- The pill in the toolbar visually updates (e.g. shows an X) while the menu is open

**What stays the same:**
- All menu content, filters, search, and interactions remain identical
- Glass button styling is preserved
- The map floating buttons (layers, draw, location) on the map view are unchanged
- Dark/light mode behavior unchanged

**Why this fixes the transition:**
- The native toolbar participates in the zoom transition correctly — it fades in place instead of sliding in from the side
- The transparent toolbar background (`.toolbarBackgroundVisibility(.hidden)`) keeps the current visual look

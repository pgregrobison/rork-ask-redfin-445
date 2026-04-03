# Move glass pill below native toolbar

**What's changing**

- **Native toolbar restored** — The system navigation bar comes back with standard toolbar items: list/map toggle on the leading side, sort menu + profile on the trailing side. No more custom floating glass buttons for these.
- **Glass pill moves below toolbar** — The "location name + X homes" pill drops just below the native nav bar, floating over the content (both list and map). It still morphs open into the location/filter menu on tap.
- **Cleaner spacing** — Remove the manual top padding hacks (56pt) on the list and map views since the native nav bar now handles safe area. The pill sits in the `safeAreaInset` or pinned overlay just below the bar.

**Design details**

- Toolbar items use standard SF Symbols as plain buttons (no glass circles) — the native bar provides its own background/material
- The glass pill remains centered horizontally, with its existing morphing animation into the expanded location menu
- Sort menu only appears in list mode (same as now), smoothly animating in/out
- Map action buttons (layers, draw, location) on the trailing edge of the map stay unchanged

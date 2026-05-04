# Restyle Filters menu to match expanded panel + add status segmented control

**Updates to the Filters menu (full filter sheet):**

- Add a native iOS segmented control at the top with **For Sale / For Rent / Sold**, no label, bound to the same listing status as the expanded panel.
- Replace the price dropdowns with the new rounded-rectangle style (44pt tall, 12pt corner radius, theme fill background, chevron-down indicator) — matching the expanded panel.
- Replace the bed/bath pill segments with the rounded-tile style used in the expanded panel: equal-width tiles, 48pt tall, rounded corners, selected tile uses system label color background with system background text.
- Update the Property Type grid to use the same rounded-tile styling (rounded corners instead of pills, same selected/unselected colors).
- Switch section labels (Price, Beds, Baths, Property Type) to the lighter primary subheadline style used in the expanded panel.
- Keep Reset / Done toolbar buttons and existing behavior unchanged.

**Out of scope:** the expanded Find panel itself, the active filter chips row, and any other screens.
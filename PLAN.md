# Replace Fluid Grow with iOS 18 Zoom Transition & Fix Duplicate Toolbars

## What's changing

**Bug fixes:**
- Remove the duplicate heart and share buttons on the detail page (caused by the Fluid Grow wrapper adding its own toolbar on top of the detail page's toolbar)
- Remove the extra back arrow showing alongside the X button in the focused photo view (same root cause)

**New transition:**
- Replace the custom "Fluid Grow" overlay with iOS 18's native **zoom transition** — the listing card visually zooms from its position on screen into the full detail page, and dismisses back into place
- This uses the standard navigation push under the hood, so there's only ever one set of toolbar items (no duplicates)

**Debug panel:**
- Rename "Fluid Grow" option to "Zoom" to reflect the new behavior
- Everything else in the debug panel stays the same

**How it works:**
- Each listing card becomes a zoom transition source
- Tapping it pushes the detail page with a zoom animation from the card's exact position
- Swiping back reverses the zoom, shrinking the detail page back into the card

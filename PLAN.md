# Fix drag handle vs scroll behavior on DP and Hybrid sheets

## Problem

Right now the drag gesture is attached to the whole sheet container (handle + scrolling content together). When the sheet is expanded and the inner content has been scrolled down, the drag gesture conflicts with the ScrollView and the handle stops feeling responsive.

## Fix

**1. Drag handle owns its own gesture**
- Move the sheet drag gesture off the whole sheet and put it directly on the small drag-handle area at the top.
- The handle will always pull the sheet up or down, regardless of where the inner content is scrolled. It will never affect scroll position — purely a sheet drag.
- Tapping/grabbing the visible capsule plus a comfortable padded hit area around it triggers this.

**2. Content-area swipes only collapse when scrolled to the top**
- When the sheet is collapsed: an upward swipe on the content area still expands the sheet (unchanged).
- When the sheet is expanded and the inner content is at the very top: a downward swipe collapses the sheet (current intent, made reliable).
- When the sheet is expanded and the inner content is scrolled down: swipes scroll the content normally and never collapse the sheet from the content area. To collapse, the user grabs the handle.

**3. Reliability tweaks for the at-top collapse**
- Slightly increase the minimum-distance threshold so accidental tiny scrolls don't trigger a collapse.
- Lower the velocity/distance threshold for committing a collapse so it feels predictable when intentional.

## Scope

Apply the same fix to both:
- The current detail page sheet
- The Hybrid variant detail sheet

No visual changes — purely interaction behavior.
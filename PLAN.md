# Clip menu content during open/close animation

**Problem**: When the location menu opens or closes, the inner content (filters, location input) visibly flies in/out above the menu boundary, spilling outside the glass container.

**Fix**: Add a content clip to the menu container so all animated content is masked within the menu's rounded rectangle shape during transitions.

- The menu will clip its children to its bounds, so content sliding in from the top stays hidden until it's inside the menu area
- No visual or behavioral changes otherwise — the menu still expands and collapses the same way
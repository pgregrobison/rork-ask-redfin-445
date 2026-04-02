# Slack-style expanding toolbar menu on Find page

**What changes**

The Find page's location menu will be rebuilt to work entirely within the native navigation toolbar, ensuring smooth zoom transitions while replicating the current custom menu behavior.

**Collapsed state (normal toolbar)**
- The list/map toggle stays as the first leading action (left side)
- The location pill becomes the second leading action, right next to the toggle — compact, showing the location name and home count
- Trailing actions (sort, profile) remain unchanged on the right

**Expanded state (menu open)**
- Tapping the location pill causes the menu to expand horizontally from the pill's position to cover the full toolbar width, then grow downward to reveal the search, filters, and action buttons
- The expansion animates with a spring, visually covering the trailing toolbar items (sort, profile) and the leading toggle
- An X button appears in the top-left corner of the expanded menu for dismissal
- Tapping outside the menu also dismisses it
- The expanded menu contains the same content as today: location search, price/beds/baths filters, and the Filter/Save Search buttons

**Why this matters**
- Using real native toolbar items means the zoom transition (list → detail) no longer causes the toolbar to fly in awkwardly from the side
- The menu overlay covers the toolbar visually but doesn't interfere with the native navigation system underneath

**Design details**
- The expanded menu uses the same glass/material background as today
- Spring animation for open/close matches the current feel
- The pill chevron or X icon toggles based on menu state, same as current behavior

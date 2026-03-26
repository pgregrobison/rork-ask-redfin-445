# Fix tab bar showing over map home card when returning from detail page

**Bug:** When you open a listing detail from the map card and navigate back, the tab bar slides in even though the map home card is still visible.

**Cause:** The detail page unconditionally shows the tab bar when it disappears, without checking if a map card is active.

**Fix:** When the detail page disappears, only show the tab bar if no listing card is currently selected on the map. This ensures the tab bar stays hidden whenever a map home card is visible.
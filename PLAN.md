# Fix tab bar not reappearing when switching from map to list view

**Bug:** Tapping a map pin hides the tab bar (because a listing is selected). Switching to list view doesn't clear that selection, so the tab bar stays hidden.

**Fix:** When the list/map toggle button is tapped, clear the selected listing so the tab bar reappears. This is a one-line change in the toggle action inside `FindView`.
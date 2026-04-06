# Fix duplicate toolbar items and leaked tab titles

**Problem**
All four tabs share one navigation bar. Even hidden tabs contribute their toolbar buttons and titles, causing 4 profile icons and visible titles from other tabs on the Find screen.

**Fix**
- Conditionally apply `.toolbar` and `.navigationTitle` only when each tab is actually selected
- Pass the current `selectedTab` into each tab view (or wrap toolbars in `if` checks) so non-active tabs don't inject toolbar items
- This ensures only the active tab's navigation bar content is shown at any time
- No visual changes to the active tab — each tab looks exactly the same as before when selected
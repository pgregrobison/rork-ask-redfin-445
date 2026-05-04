# Stop the Find header from sliding in when switching tabs

**The problem**

The location/search pill at the top of the Find tab is currently attached to the whole app shell, with a rule that says "only show on the Find tab." Every time you tap into Find from another tab, the pill is freshly added and animates in from the top — that's the janky slide you're seeing.

**The fix**

- Anchor the Find header pill inside the Find tab itself, instead of at the app root.
- Result: switching between tabs swaps the whole screen at once (as expected), and the pill is simply already there when you land on Find — no slide-in animation.
- Behavior on Find stays identical: same pill, same expand/collapse for the location menu, same hide-when-viewing-a-listing rule.

**What stays the same**

- All other tabs are untouched.
- The expanded location menu, filters sheet, and save search continue to work exactly as today.
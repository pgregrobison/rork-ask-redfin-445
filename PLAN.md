# Make debug panel accessible from all tabs with large detent

**What changes:**

- The profile icon button (top-right) on **every tab** (Find, For You, Saved, My Home) will open the debug panel — not just My Home
- The debug panel sheet will support both **medium** and **large** heights, so you can pull it up to see all options as you add more

**How it works:**

- The debug panel sheet moves to the main app level so it's shared across all tabs
- Each tab's existing profile button gets wired up to open it
- The sheet starts at medium height and can be pulled up to large


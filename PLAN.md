# Fix native tab bar to show outlined icons when not selected

**Why this is happening**

iOS automatically forces every icon in a native tab bar to its filled variant — even if you pass the outlined name like "binoculars". That's why the accessory layout always looks filled, while the custom in-app tab bar (which doesn't have this system override) works correctly.

**The fix**

In the accessory tab bar, give each tab a custom label that:
- Explicitly opts out of the system's automatic "always fill" behavior
- Shows the outlined icon when the tab is not selected
- Shows the filled icon when the tab is selected

This will make Find, For You, Saved, My Home, and My Redfin all behave the same way as the in-app variant — outlined when inactive, filled when active.

No visual changes elsewhere; only the accessory native tab bar icon rendering is affected.
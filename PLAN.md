# Fix native tab bar to use outlined icons that auto-fill on selection

**What's wrong**

In the native (iOS 26) tab bar layout, the icons aren't swapping between outlined and filled when you select different tabs — for example, "Find" stays on the same icon instead of switching to filled binoculars when active.

**Fix**

- Update each tab in the native tab bar to use the outlined symbol name only (e.g. binoculars, heart, house). iOS automatically renders the filled variant for the selected tab, so the selected/unselected state will work correctly without any manual swapping.
- Leave the custom tab bar (older iOS fallback) untouched — it already handles outline/fill correctly on its own.

**Result**

When you tap "Find", you'll see filled binoculars; the other tabs show outlined icons. Same for Saved (heart/heart.fill), My Home (house/house.fill), My Redfin (person.crop.circle/person.crop.circle.fill), and For You.
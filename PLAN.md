# Limit brand red to the native tab bar only

**The problem**

Right now the brand red is leaking out of the native tab bar and tinting icons and buttons across the rest of the app (in pages like Find, For You, Saved, My Home, and My Redfin).

**The fix**

- Keep the native tab bar's selected icon and label colored in Redfin brand red.
- Reset the page-level tint back to the standard primary color inside every tab's content, so buttons and icons on each screen are no longer red.
- No other visual changes — page layouts, existing accents (greens, etc.), and the tab bar itself stay exactly as they are today.

**Result**

Only the selected tab's icon and text in the bottom tab bar will appear in Redfin red. Everything inside the screens above the tab bar will use the neutral, theme-correct color again.
# Fade-in toolbar on detail page during zoom transition

**What changes:**

- When navigating to a listing detail page, the navigation bar buttons (heart, share, back) will start fully invisible
- After the zoom transition finishes (~0.35s), the toolbar items will smoothly fade into view
- This eliminates the "slide-in" feel and makes the toolbar appear to materialize in place
- The fade-in applies to all toolbar items (back button area, heart, share, and any focus-mode items)
- On dismiss, toolbar opacity resets so it's ready for the next navigation
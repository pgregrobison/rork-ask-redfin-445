# Switch detail page to standard navigation toolbars

**What changes:**

- **Remove the custom floating header** on the detail page (the manually positioned back/heart/share buttons)
- **Replace with standard navigation toolbar items** — back button handled by the system, heart and share as trailing toolbar items — matching the same sizing and style as the map page toolbar
- **Remove `.navigationBarHidden(true)`** so the system navigation bar is visible and transitions cleanly from the map page
- **Focus photo overlay** will keep its own close/heart/share buttons as an overlay (since it's a modal-like state on top of the detail page, not a navigation push)

This gives you the clean, native slide-in toolbar transition when tapping a listing from the map.
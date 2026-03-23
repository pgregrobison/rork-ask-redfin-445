# Restore native toolbar transitions and floating glass footer on details page

## Changes

### **Navigation Toolbar**
- Remove the custom overlay nav header (the manually positioned glass X/heart/share buttons at the top of the detail page)
- Use the native navigation bar toolbar instead, so pushing from the map to the detail page gets a smooth, system-animated toolbar transition
- **Leading toolbar item**: Back chevron button (native back behavior via NavigationStack)
- **Trailing toolbar items**: Heart (favorite toggle) and share button, styled as glass action buttons
- The navigation bar will use an inline display mode with a transparent background so the photos show through behind it

### **Sticky Footer**
- Remove the solid `.ultraThinMaterial` background from the footer bar
- Make it a row of floating, standalone glass buttons — the red "Request showing" pill and the sparkle glass button — sitting directly over the content with no backing bar
- The buttons themselves provide their own visual weight; no full-width background strip needed

### **What stays the same**
- The photo scroll, draggable detail sheet, expanded content, and all detail sections remain unchanged
- The focused photo viewer keeps its own custom header (since it's a full-screen cover, not a navigation push)

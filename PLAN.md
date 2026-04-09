# Offset map camera to account for chat sheet

When the chat sheet appears at the 70% detent after a search, the map pins currently get hidden behind the sheet. This change will adjust the map camera so all pins are visible in the upper portion of the screen above the sheet.

**What changes:**
- When fitting pins with the map focus sheet active, the map will zoom out more and shift the center point upward so all pins sit comfortably in the visible area above the sheet
- The same offset logic applies when fitting a single listing — it will also account for the sheet
- No visual or design changes to the sheet itself — just smarter map camera positioning

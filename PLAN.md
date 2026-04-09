# Fix scroll lock on fraction detent

**Problem:** When the chat sheet is at the 70% detent, attempting to scroll still engages the ScrollView. You have to scroll all the way to the top before the drag gesture transitions to pulling the sheet up.

**Fix:** Completely disable scrolling on the chat's ScrollView when the sheet is at the fraction detent. This ensures any vertical drag immediately pulls the sheet up to the large detent, rather than fighting with the scroll position. Once at the large detent, scrolling re-enables as normal.

**What changes:**
- The chat message list will be non-scrollable when the sheet is in its smaller (70%) position
- Dragging up on the chat content will immediately expand the sheet to full height
- Once expanded, scrolling works exactly as it does today
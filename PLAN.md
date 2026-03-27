# Persist chat scroll positions across sheet open/close

**Problem**
When you close and reopen the Ask Redfin chat, every thread scrolls to the top because the scroll position data is lost when the sheet disappears.

**Fix**
- Move the scroll position memory from the sheet into the persistent chat data layer (which stays alive even when the sheet is closed)
- When you close the sheet, the current scroll position is saved
- When you reopen the sheet, it automatically scrolls back to where you left off
- Each thread remembers its own independent scroll position

**What you'll experience**
- Open a chat thread, scroll partway through, close the sheet → reopen and you're right where you left off
- Switch between threads — each one remembers its own position
- New messages still scroll as expected when you send them
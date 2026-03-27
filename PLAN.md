# Fix auto-scroll triggering when bot finishes responding

**Problem**
When the bot finishes its response and the action bar appears, the chat auto-scrolls down — undoing the user's scroll position.

**Root cause**
When streaming ends, the code immediately sets the scroll phase to "idle" and collapses the spacer. But the action bar appearing right after causes a layout change, and since the phase is already "idle", the auto-scroll kicks in.

**Fix**
- Keep the scroll phase in "streaming" mode while collapsing the spacer
- Only transition to "idle" after a short delay (e.g. 0.5s), giving the action bar time to appear without triggering auto-scroll
- This ensures no bot-related layout change ever triggers auto-scroll
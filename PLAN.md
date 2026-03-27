# Fix bot response auto-scrolling back during streaming

**Problem**
When a bot response streams in, the chat scrolls back down — undoing the "pin user message to top" behavior. This happens because the "thinking" indicator ends before streaming finishes, which prematurely resets the scroll phase to idle. Once idle, every content update triggers a scroll-to-bottom.

**Fix**
- When thinking ends and the phase is "streaming," don't collapse the spacer yet — leave it for the streaming-finished handler
- When streaming finishes, smoothly collapse the spacer and reset the phase
- Also guard the content-change handler so it never scrolls to bottom while the bot is still actively streaming (even if phase accidentally becomes idle)
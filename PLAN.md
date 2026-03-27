# Stop bot response from auto-scrolling away from user message

**Problem**
After sending a message, the user's message correctly slides up to just below the header. But then the bot's streaming response triggers auto-scroll handlers that pull the view back down, undoing the positioning.

**Fix**
Remove all auto-scroll-to-bottom behavior that fires during and after bot response streaming. The scroll position set by the user-sent animation will be preserved naturally as new content appears below.

Specifically:
- When a new bot message arrives after a user send, do **not** scroll to bottom — just transition the phase to `.streaming` silently
- When the thinking indicator appears during `.userJustSent`, do **not** scroll to bottom
- While the bot response is streaming (content updating), do **not** scroll to bottom
- When streaming finishes, collapse the bottom spacer but do **not** force-scroll to bottom — let the content settle naturally

This means the user's message stays pinned near the top of the viewport, and the bot response simply fills in below it as it streams.
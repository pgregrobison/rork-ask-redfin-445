# Fix user message auto-scroll to top of chat viewport

**Problem**
When you send a message, it should smoothly slide up to sit just below the header. Instead, it stays near the bottom or scrolls partway and bounces back.

**Root Causes Found**
1. The invisible space added below the message (to make room for scrolling) is too short — it doesn't account for how tall the actual message is, so the scroll view can't physically push the message all the way to the top
2. The scroll fires before the extra space has been fully measured and rendered
3. Other scroll handlers (for bot responses, thinking indicator) can override the upward scroll mid-animation

**Fixes**
- **Generous spacer**: Use the full viewport height as the spacer size instead of subtracting a fixed 120pt — this guarantees any message, regardless of height, can reach the top
- **Two-phase trigger**: First add the spacer (frame 1), then trigger the scroll on the *next* frame (frame 2) so the layout is definitely ready before scrolling begins
- **Scroll lock during transition**: All competing scroll handlers (message count changes, thinking state, content streaming) will be suppressed while the "scroll to top" animation is active, preventing any interference
- **Clean teardown**: When the bot finishes responding, the spacer is removed and normal scroll-to-bottom behavior resumes seamlessly
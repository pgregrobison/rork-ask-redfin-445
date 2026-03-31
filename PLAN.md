# Fix chat over-scroll into blank space

**Problem**
- After sending messages back and forth, users can scroll far below the last message into empty white space
- This happens because a large spacer is added when sending a message (to push it to the top of the screen) but is never removed after the AI response finishes

**Fix**
- After the AI response finishes streaming, shrink the spacer back to zero so there's no extra blank space below the conversation
- Same fix applied for voice mode responses
- All existing scroll behaviors (auto-scroll on send, auto-scroll on input focus, scroll restoration) remain untouched
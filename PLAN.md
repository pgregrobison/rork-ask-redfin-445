# Fix auto-scroll: user messages slide to top after sending

**Problem**
When a user sends a message, it should scroll up to sit just below the header with the "Thinking..." indicator right beneath it — leaving the rest of the screen empty. Currently, the scroll can't reach that position because there isn't enough content below the message to allow the scroll view to push it to the top.

**Fix**
- Measure the visible scroll area height
- After a message is sent, add a tall bottom spacer (roughly screen-height) inside the scroll content so the scroll view has enough room to position the user message at the top
- The spacer shrinks/disappears once the bot response comes in and fills the space naturally
- Ensure the scroll animation targets the user message with a `.top` anchor reliably
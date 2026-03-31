# Fix chat spacer behavior — only remove when content fills viewport or user scrolls up

**What's changing:**

The bottom spacer in the chat (which pushes new messages to the top of the screen) currently disappears as soon as the bot finishes responding. Instead, it should stick around until the chat naturally fills the screen or the user scrolls up.

**New behavior:**

- When a message is sent, a spacer appears to keep the user's message near the top
- The spacer stays even after the bot finishes responding
- The spacer only disappears when:
  1. The total chat content grows taller than the visible area, **or**
  2. The user manually scrolls upward
- Once removed, the spacer stays gone for that scroll session
- When the user sends another message, the spacer reappears and the cycle repeats

**What stays the same:**

- Auto-scroll to user messages on send
- Auto-scroll on input focus
- All voice mode scroll behavior
- Thread switching behavior
- Header gradient and input bar

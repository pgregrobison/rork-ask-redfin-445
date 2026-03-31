# Fix chat bounce by removing the spacer entirely

**Problem**
When the chat has more than a screen of messages, sending a new message causes a visual "bounce" — the message jumps up then snaps back down due to an invisible spacer being added and then immediately collapsed.

**Fix**
- Remove the bottom spacer system completely — no more invisible spacer below messages
- When a message is sent, simply scroll so the new user message lands near the top of the screen
  - For long conversations, this works naturally since there's plenty of content above
  - For short conversations, the message will be as high as possible given the content — it starts at the top of the scroll area
- The thinking indicator and incoming bot response will appear below the user message, keeping it positioned well
- All other behaviors stay the same: auto-scroll on input focus, scroll position saving between threads, voice mode scroll, keyboard dismiss on scroll, etc.
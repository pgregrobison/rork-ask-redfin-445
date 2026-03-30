# Anchor voice transcript to top of viewport

**What changes**

When voice mode starts transcribing the user's message, it will scroll up so the message anchors to the top of the chat viewport — matching the same behavior that already happens when you send a regular typed message.

**How it will work**

- As soon as the first word of the transcript appears, the chat scrolls so the user's message sits at the top of the screen
- The large bottom spacer pushes content up, keeping the message pinned at the top while more words stream in
- This reuses the exact same scroll-to-top mechanism already used for sent messages
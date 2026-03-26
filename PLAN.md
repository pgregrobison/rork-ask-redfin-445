# Add send button to chat input & save scroll position per thread

**Features**
- A circular send button (arrow up icon) appears inside the text input area when the user has typed something
- The button uses system colors — dark fill with a light arrow in light mode, and the inverse in dark mode — matching the screenshot's iMessage-style look
- Tapping the send button sends the message (same as pressing return)
- When switching between chat threads, each thread remembers where the user scrolled to, so they can pick up right where they left off

**Design**
- The send button is a filled circle sitting to the right of the text field, inside the input capsule
- It only appears when there's text to send (hidden when the input is empty and not streaming)
- Uses `arrow.up` SF Symbol inside a filled circle, styled with `.primary` / `.background` system colors for automatic light/dark mode support
- Smooth appearance/disappearance animation when text is entered or cleared

# Fix chat scroll: user message slides to top on send

**What changes**

- When the user taps the send button, their message smoothly slides up to sit just below the header at the top of the visible area
- The "Thinking..." indicator appears below the user message, with plenty of empty space beneath — exactly as shown in the screenshot
- As the bot response streams in, the view stays anchored to the user message at top until the response is long enough to fill the screen, at which point it begins auto-scrolling to keep the latest text visible
- The keyboard dismisses automatically after sending a message so the full chat area is visible

**How it works**

- After sending, scroll anchors the user message to the top instead of chasing the thinking indicator to the bottom
- A flag tracks when we're in "just sent" mode so the thinking indicator and early streaming don't fight the scroll position
- Once the bot response finishes streaming, normal bottom-anchored scrolling resumes for future messages
- Keyboard is dismissed on send for a clean transition matching the screenshots

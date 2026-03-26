# Fix chat scroll: user message should slide to top after sending

**Problem**
When you send a message, it stays near the bottom of the screen instead of scrolling up to sit just below the header (as shown in your screenshot).

**Root cause**
The extra space needed to allow the message to scroll to the top only gets added *after* the scroll has already happened — so there's nothing to scroll into and the message stays put.

**Fix**
- Ensure the extra scroll space is added *before* the scroll is triggered
- Add a dedicated scroll trigger that fires once the layout has updated with the new space
- The result: after tapping send, your message smoothly slides up to the top of the chat area, with "Thinking..." right below it and empty space beneath — exactly matching the screenshot
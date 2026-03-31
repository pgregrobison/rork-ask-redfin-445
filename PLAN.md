# Fix chat scroll: use content margins instead of spacers

**Problem**
The scroll-to-top behavior (user message appearing just beneath the header) needs to work in all scenarios. Previous spacer-based approaches caused visual bouncing, layout glitches, or broke when the conversation got long.

**New approach: Content margins instead of spacers**

Instead of inserting an invisible spacer element into the message list (which is real content the user can scroll into), use the scroll view's built-in **bottom content margin** — sized to the full viewport height. This is a fundamentally different mechanism:

- **Content margins** tell the scroll view "there's extra padding beyond the content" — like a cushion at the bottom. The scroll view natively rubber-bands when you reach it, just like reaching the end of any iOS list.
- **A spacer element** is real content you can freely scroll through — that's what created the "blank space" issue.

**What this achieves:**

1. ✅ Sending a message always scrolls it to just beneath the header — works for short and long conversations alike
2. ✅ No dynamic add/remove of spacers — the margin is always there, set once
3. ✅ No layout "bounce" — nothing is being inserted or removed from the content
4. ✅ Scrolling past the last message feels natural — iOS rubber-band bounce pulls you back, just like the bottom of any native list
5. ✅ When scroll ends in the empty margin zone, auto-snap back to the last message

**What stays the same:**
- All existing auto-scroll behavior on send, input focus, voice mode, and thread switching
- Header gradient, input bar, thread switcher
- Keyboard interactive dismiss

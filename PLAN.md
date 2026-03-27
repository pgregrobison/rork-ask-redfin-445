# Fix auto-scroll: user message slides to just below header

## Diagnosis

The current approach adds a tall invisible spacer *conditionally* when a message is sent, then tries to scroll to the message in the same frame. SwiftUI's lazy layout hasn't measured the spacer yet, so the scroll has nowhere to go — it silently fails or undershoots.

## Fix Strategy

Replace the fragile conditional-spacer + delayed-scrollTo approach with a reliable two-phase system:

**1. Always-present bottom spacer (not conditional)**
- A spacer at the bottom of the message list that's always in the layout — not inserted on-the-fly
- Its height starts at 0 and animates to fill the visible scroll area when a message is sent
- Because it's always in the tree, SwiftUI's layout engine already knows about it — no timing issues

**2. Two-phase scroll after send**
- **Phase 1 (immediate):** Set the spacer height to the full visible area minus a small offset for the message. This pushes the content size up so there's room to scroll.
- **Phase 2 (next frame, ~0.1s):** Animate `scrollTo(messageId, anchor: .top)` which now has enough content below to succeed.

**3. Switch from LazyVStack to VStack for reliability**
- `LazyVStack` defers measurement of off-screen items, which breaks `scrollTo` positioning
- For a chat with moderate message counts, `VStack` inside `ScrollView` gives accurate, predictable scrolling
- This is the single biggest fix — lazy stacks are a known source of `scrollTo` failures

**4. Clean up state management**
- Remove `pendingScrollTarget` indirection — scroll directly after a short layout delay
- Remove `scrollLocked` flag in favor of a simpler "phase" enum (idle / userJustSent / streaming)
- When the bot response finishes, smoothly shrink the spacer back to 0 and scroll to bottom

## Expected Result
- User taps send → message slides up and rests just below the navigation bar header
- Bot "thinking" and response appear below with room to stream in
- When response completes, spacer collapses and chat scrolls naturally to show the full conversation

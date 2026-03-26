# Improve Chat UI — Message Input, Alignment, Feedback, Scrolling & Welcome Message


## Changes

**Message Input**
- Users can type and send messages via the existing text field (already functional)

**Bot Messages — Left Aligned**
- Bot/assistant messages will be left-aligned instead of centered, matching the design screenshots
- Text and content hugs the left edge with proper padding

**Feedback Thumbs Up/Down**
- Thumbs up and thumbs down buttons only appear once the bot has finished its full response (not while streaming)
- Already partially implemented — will verify the `isStreaming` guard is working correctly

**Auto-Scroll Behavior**
- When a user sends a message, the scroll view auto-scrolls the user message to just below the navigation header (top-anchored), leaving room below for the bot's thinking indicator and response to appear

**Thread Dropdown — Remove Sparkle Icon**
- Remove the sparkle icon from the thread switcher menu label in the navigation bar

**Close Button Styling**
- Replace the current `xmark.circle.fill` close button with a `GlassActionButton` using the "xmark" icon, matching the consistent close button style used on map cards and elsewhere in the app

**Welcome Message Instead of Empty State**
- Replace the "Ask Redfin" splash screen (sparkle icon, title, suggestions) with an initial bot message bubble: *"Hey there! I see you're looking near Garner and Raleigh. I can help you find the perfect home — just let me know what you're looking for, and I'll take care of the rest."*
- This message appears as a standard left-aligned assistant bubble when a new thread is created

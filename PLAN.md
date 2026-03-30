# Reduce map shift and remove "Ask me about homes" nudge

**Changes:**

1. **Reduce the upward map shift** when zooming to show user location + Compass listing — the current offset pushes the pins too far up. Will reduce the card offset ratio from `0.4` to `0.2` so the map centers more naturally while still accounting for the bottom card.

2. **Remove the "Ask me about homes in NYC!" nudge bubble** — delete the nudge text, timer, bubble view, and all related state so it no longer appears.
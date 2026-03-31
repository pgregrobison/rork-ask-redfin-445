# Fix thinking indicator position shift and restore dot animation

**What's being fixed:**

1. **Position shift between "Thinking" and "Searching homes"** — Currently, a new message gets inserted above the indicator right before it switches to "Searching homes", which pushes it down. The fix delays inserting that message until after the searching phase finishes, so the indicator stays in the same spot throughout.

2. **Dots no longer bounce** — The bounce animation only starts when the indicator first appears on screen, but the indicator never truly disappears (it just shrinks to zero height). So the animation never restarts. The fix will use a continuous timer-driven animation that runs whenever the indicator is visible, ensuring the dots always bounce.
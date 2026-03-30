# Fix voice mode mute button styling and behavior

**Fixes:**

1. **Mute button color** — Remove any accent blue tinting; use system black/white (`.primary`) for the icon and `tertiarySystemFill` background in the default (unmuted) state

2. **Muted state styling** — When muted, show a filled red circle background with the mic.slash.fill icon in white

3. **Tapping mute no longer sends a message** — The voice simulation will pause/stop word accumulation while muted, so tapping mute only toggles the visual state without triggering a new user message

4. **Voice simulation respects mute** — The simulated voice input loop will check the muted state and wait while muted instead of continuing to stream words
# Pause tour day at first stop until voice mode is tapped

## Changes to tour day flow

- **Pause at first stop**: After arriving at stop 1 and showing the "Tap the 🎙️ and let me know what you thought of this home!" prompt, the auto-progression stops. Stops 2, 3, and 4 will not appear until the user takes action.
- **Voice mode resumes the tour**: When the user taps the voice mode button while paused on stop 1, the simulated transcript becomes "I really liked all the natural light and vaulted ceilings, but the kitchen was way too small." After the assistant acknowledges, the tour automatically continues with stop 2 and proceeds normally through stops 3 and 4.
- **Summary update**: The post-tour recap to the agent now uses the user's exact words for the first home: "Loved the natural light and vaulted ceilings, but the kitchen was way too small." The other three bullets stay as-is.

## Out of scope
- Voice phrase outside of tour day stays unchanged.
- Stops 2–4 still auto-progress on their existing timers.

# Add smooth map panning animation when tapping pins

**What changes**

- When you tap a pin, the map will now smoothly slide to center on that pin — just like Apple Maps does
- Uses a quick spring animation so it feels responsive but not jarring
- Rapid pin taps will interrupt the previous animation and start sliding to the new pin immediately

**How it works**

- The pin selection already updates the map camera position — it just needs to be wrapped in an animation so MapKit interpolates between the old and new positions instead of jumping instantly
- Same animation style already used for the "locate me" button, now applied consistently to pin taps too

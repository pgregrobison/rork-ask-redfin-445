# Eliminate the system-color flash before splash

**The fix**

- Lock the launch background color to Redfin red in **both** light and dark appearances explicitly, so iOS never falls back to a system color while resolving the asset.
- Tint the underlying app window itself Redfin red, so even the briefest pre-render frame (during the icon-zoom-to-app transition) shows red instead of the system background.
- Make the very first frame of the app's root view also Redfin red, ensuring a seamless red-on-red handoff from launch screen → splash → content.

**Result**

Tapping the app icon will show solid Redfin red instantly and continuously — no white/black flicker in either light or dark mode — until the splash logo fades into the app.
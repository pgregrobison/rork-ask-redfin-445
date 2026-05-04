# Fix the black flash on app launch

**What's happening**

When you tap the app icon, iOS shows its own built-in launch screen *before* the app's code ever runs. Right now that built-in launch screen is misconfigured, so it renders as solid black for a moment until our custom splash takes over.

**The fix**

- Place the actual Redfin logo image files into the launch screen image slot so iOS has something to draw. Right now the slot is empty, which is why iOS shows nothing.
- Correct the launch screen configuration so the Redfin red background and the centered logo are baked into the system-level launch screen — the same screen iOS shows the instant you tap the icon.

**Result**

The moment you tap the app icon, you'll see the Redfin red background with the white logo centered — instantly, with no black flash. Our animated splash screen then smoothly takes over with its scale/fade-in animation, so the handoff is invisible.
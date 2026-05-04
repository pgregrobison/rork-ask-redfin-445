# Fix the system-color flash before the red splash

## What's wrong

The OS-level launch screen is currently empty, so iOS shows the default system background (white in light mode, black in dark mode) for a split second before our app's red splash takes over. Other apps like OpenTable and the real Redfin avoid this because their OS-level launch screen is itself painted with the brand color.

The settings we tried to use to set the launch background color and logo were silently ignored by iOS — they were written in a way the system doesn't actually read.

## The fix

- Provide a proper launch screen configuration so iOS itself paints the screen Redfin red with the centered Redfin logo from the very first frame — before any code runs.
- This makes the transition from app icon → splash seamless: red the entire time, exactly like OpenTable and the live Redfin app.

## What you'll see

- Tap the app icon → instantly Redfin red with the centered Redfin logo.
- No white flash in light mode, no black flash in dark mode, on any device.
- The existing splash animation and timing stays the same.
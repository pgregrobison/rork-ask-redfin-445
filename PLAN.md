# Fix crash when tapping Tour Day notification from background

**The problem**

When you tap the Tour Day notification while the app is in the background, the system delivers the tap to the app in the same instant the scene is still waking up. The app reacts immediately by clearing the navigation stack, switching tabs, opening the chat sheet, and kicking off the tour-day script — all while the UI hasn't finished becoming active yet. That race causes the crash.

**The fix**

- Wait until the app is fully foregrounded (scene becomes active) before acting on a Tour Day notification tap. If a tap arrives while still in the background, it's queued and runs the moment the app is visible.
- When the trigger fires, dismiss any other sheet that may be open first, then open the Tour Day chat after the foreground transition settles. This avoids the "presenting one sheet on top of another" crash path.
- Run the chat-sheet open and the tour-day script on the next run loop (instead of synchronously inside the change handler), so SwiftUI can finish its current update before we mutate navigation, tab selection, and presentation state.
- Make the Tour Day script safe to start when the chat sheet is already open (no double-trigger, no overlapping scripts).

**What you'll experience**

- Lock the phone, get the Tour Day notification, tap it → the app reliably opens to the Tour Day chat with the route, no crash.
- If you tap it while the app is already foregrounded, behavior is unchanged.
- If another sheet (like the debug panel) happens to be open, it closes cleanly first before the Tour Day chat appears.
# Revert tour day trigger to a fake in-app notification banner

**What changes**

- When you mention "tour day" in Ask Redfin, instead of scheduling a real iOS push notification, the app will drop down a fake iOS-style notification banner from the top of the screen.
- Tapping the fake banner opens Ask Redfin and starts the Tour Day flow (new thread, route map, voice prompts) just like before — no system permissions, no backgrounding, no crashes.
- The banner auto-dismisses after a few seconds if not tapped, and can be swiped up to dismiss.

**Look & feel**

- Mimics the native iOS notification: rounded rectangle with thin material background, small Redfin app icon on the left, bold title "Welcome to tour day!" and body "I've created a new thread for all things tours."
- Subtle drop-in spring animation, soft shadow, respects light/dark mode.

**Cleanup**

- Removes the real local-notification scheduling and tap-handling for tour day (the compass "coming soon" notification stays untouched).
- Removes the scene-phase / pending-trigger plumbing that was causing the crash on tap.

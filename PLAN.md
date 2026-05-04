# Make the splash logo appear instantly on launch

**The problem**

Right now you briefly see black, then the red splash with the logo. That's because only the red background is baked into the iOS-level launch screen — the logo lives in a SwiftUI view that can only render after the app process boots. The fix is to put the logo on the native launch screen itself so it appears the instant you tap the icon, then crossfade into the app.

**What you'll see**

- Tap the app icon → red background with the centered Redfin logo appears immediately, with no black flash.
- The SwiftUI splash (same red, same logo, same size) takes over seamlessly so the handoff is invisible.
- It then crossfades into the app content as it does today.

**Changes**

- Add the Redfin logo to the native iOS launch screen, sized and centered to match the current SwiftUI splash exactly (~200pt wide, white).
- Keep the existing SwiftUI splash overlay so the transition into the app stays smooth.
- No visual changes to the app itself — only the very first moment of launch is affected.
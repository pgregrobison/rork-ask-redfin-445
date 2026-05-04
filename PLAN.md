# Make splash logo match launch screen exactly so the handoff is invisible

**The problem**

When the app launches, the system shows the native launch screen (red background + Redfin logo) for a moment, then hands off to our in-app splash (also red + Redfin logo) before fading to the main app. Because the in-app splash uses a slightly different logo image and an entrance animation (logo grows from 85% and fades in), the logo visibly *jumps* during that handoff.

**The fix**

Make the in-app splash a pixel-perfect continuation of the native launch screen, so you can't tell when one ends and the other begins. Then it simply fades out to reveal the app.

- Use the exact same logo asset and size as the native launch screen (200pt wide, centered, white).
- Remove the scale + fade-in entrance animation on the splash logo so it appears already at full size and full opacity — identical to where the system left it.
- Keep the brief hold, then cross-fade the whole splash layer out to reveal the main app underneath (logo doesn't move during the fade).
- Keep the red background everywhere it already is (window tint, splash, launch background) so there's never a flash of system color.

**Result**

Tapping the icon now feels like one continuous moment: red + logo appears instantly, holds, then smoothly dissolves into the home screen — no logo jump, no second "appearance" animation.
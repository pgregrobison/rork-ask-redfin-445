# Minimize tab bar + accessory on map pan via scroll driver

**Behavior**

- As soon as the user starts panning or zooming the map (in Find tab, map view, no detail page open), the tab bar collapses into its minimized pill and the Ask Redfin accessory shrinks to its compact form — same look as when a home card is shown.
- The minimized state stays put while the map is being interacted with, and remains minimized after the user lifts their finger.
- The tab bar + accessory only restore to full size when the user taps a tab bar icon (or otherwise switches context, e.g. opens the list view, opens a detail, or dismisses to the empty map). Tapping the same Find tab again "resets" it back to expanded.
- Tapping a map pin keeps things minimized (already wired through the home-card path) and the home card sits above the minimized bar.

**How it works under the hood**

- Reuse the existing hidden `AccessoryScrollDriver` ScrollView — that's what drives Apple's `.tabBarMinimizeBehavior(.onScrollDown)` system collapse.
- Replace its current "snap to top/bottom on a Bool" logic with a small state machine that owns whether the accessory should be **minimized** or **expanded**, and animates the hidden ScrollView's offset accordingly (down to collapse, back to top to expand). This is the most reliable path because it lets the system tab bar follow naturally.
- Drive that state from three signals already present in the view model:
  1. `noteMapCameraChanging` (existing) → set state to minimized. Remove the auto-idle reset so it sticks.
  2. Home card shown (`isCardVisible`) → minimized.
  3. Tab tap, navigation push, list view toggle, or returning to a clean map → expanded.
- Add a tiny "tab tapped" hook on the `TabView` selection binding so reselecting Find (or switching tabs) re-expands.

**Edge cases handled**

- If a programmatic camera animation runs (fit listings, fit neighborhoods, compass focus), it won't trigger minimize (already gated by `isAnimatingCamera`).
- Detail page push/pop continues to use its existing show/hide tab bar logic.
- Non-accessory layout (legacy tab bar) is unaffected.

**Out of scope**

- No visual redesign of the minimized tab bar or accessory — only the trigger logic changes.
- No changes to detail page sheet behavior or Ask Redfin placeholders.
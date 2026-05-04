# Drive accessory minimize via a real, gesture-forwarded scroll view on the Find map

## Problem

The accessory bar isn't reliably minimizing when you pan/zoom the map. The current trick (a hidden SwiftUI ScrollView programmatically scrolled in response to `isMapInteracting`) doesn't appear to be observed by iOS 26's `tabBarMinimizeBehavior(.onScrollDown)`, because that API watches user-driven scroll on a real, visible scroll view in the foreground.

## New approach (Find map only)

Build a thin UIKit-backed scroll-driver that the system treats as the page's primary scroll content. Forward every map gesture into it, scoped strictly to the Find tab's map view.

### What changes
- **Find map view (accessory mode only):** wrap the map in a transparent `UIScrollView` overlay (full-bleed, content taller than the viewport so it's scrollable). The scroll view passes touches through to the map (`isUserInteractionEnabled = false` on the scroll view itself; pan recognition handled separately) so map gestures continue to work.
- **Gesture forwarding:** attach a simultaneous `UIPanGestureRecognizer` and `UIPinchGestureRecognizer` to the map's hosting view. Translate their deltas into `scrollView.contentOffset` updates so the tab-bar minimize machinery sees real, user-driven scroll deltas. Any pan or pinch nudges offset down → bar minimizes; an upward pan / settling can nudge offset up → bar restores (we'll keep it minimized while interacting and let the existing "sticky" behavior bring it back as today).
- **Belt-and-braces:** also bridge `onMapCameraChange(.continuous)` into a tiny `setContentOffset` nudge so programmatic camera changes (e.g., locate-me) still minimize.

### Strict scoping
- Lives only in `FindMapView` and only when `accessoryMode == true`.
- Does **not** mount in `FindListView`, the For You / Saved / My Home / My Redfin tabs, or the legacy custom tab-bar layout.
- Existing `AccessoryScrollDriver` (background, programmatic) is removed for the Find map case; other call sites (if any remain useful) are left untouched. The `stickyMinimized` / `isMapInteracting` plumbing stays in place as a safety net but is no longer the primary driver.

### Behavior
- Pan map → accessory bar collapses immediately.
- Pinch-zoom map → accessory bar collapses.
- Programmatic camera moves (locate-me, listing select) → accessory bar collapses.
- Switching to list view, navigating to a detail page, or switching tabs → accessory bar restores (unchanged).
- List view scroll behavior, other tabs' headers, and the non-accessory layout: unaffected.

### Validation
Run `runChecks` after the edits and verify the build is clean.
# Make map pan/zoom minimize the tab bar like list scroll-down

## Problem

In the accessory variant, scrolling down on a list view smoothly minimizes the tab bar + Ask Redfin accessory. But panning or zooming the map currently does nothing — the bar stays full-size. The hidden scroll driver we use today isn't being recognized by iOS 26's tab bar minimize behavior because it's marked non-interactive.

## What will change

**Map gestures minimize immediately**
- Any pan or zoom on the map (the moment the gesture starts) will minimize the tab bar and Ask Redfin pill, exactly matching the scroll-down animation used on list views.
- The minimize will be driven through a real scroll-geometry signal so iOS animates it natively (smooth, system-matched feel) instead of snapping.

**Stays minimized until you tap to restore**
- Once minimized, the bar stays compact even after the map stops moving — no auto-restore on idle.
- Tapping the minimized tab bar area or the Ask Redfin accessory pill restores the full-size bar.
- Switching tabs, opening the list view, opening a listing card, or navigating into a detail page also restores it (existing behavior preserved).

**No change to list view behavior**
- List views keep their current native scroll-down-to-minimize / scroll-up-to-restore behavior untouched.

## Why it didn't work before

The invisible driver behind the map was both hit-test-disabled and scroll-disabled, so the system never treated it as an active scroll surface and never fired the minimize animation. The fix is to replace it with a properly registered (but visually invisible and touch-passthrough) scroll surface that the system recognizes, and to drive its offset whenever the map reports a camera change.

## Restore tap target

A thin, transparent tap zone will sit over the minimized tab bar / accessory area only while minimized. Tapping it (or the accessory pill itself) brings the bar back to full size with the same native animation.
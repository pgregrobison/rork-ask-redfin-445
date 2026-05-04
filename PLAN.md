# Forward map pans through a real scroll view to trigger native tab-bar minimize

## What's changing

Right now, panning the map on the Find tab is supposed to minimize the bottom Ask Redfin accessory bar — but the trick we tried (an invisible scroll view nudged programmatically) doesn't actually trigger the system's minimize behavior, because iOS only reacts to real finger-driven scrolling.

## New approach

I'll put a transparent scroll layer **on top of** the map. As you drag your finger, that scroll layer scrolls (which is what the system needs to see in order to minimize the accessory bar), and the same drag is simultaneously passed through to the map so it pans/zooms exactly as before.

## Behavior

- **Map view of Find only.** No other tab, page, or the list view is affected.
- **Panning, zooming, or rotating the map** all minimize the accessory bar, just like scrolling a feed does elsewhere in the app.
- **Re-expanding** works exactly like the rest of the OS: the accessory stays minimized until you tap the minimized tab bar, matching the native behavior on every other screen.
- Tapping pins, the map action buttons (layers / draw / locate), and the listing card overlay all keep working — the transparent layer doesn't swallow taps, only drags.

## Cleanup

- The old invisible-scroll-view driver and its camera-change "pulse" plumbing get removed since they're no longer needed.
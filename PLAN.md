# Fix map card dismiss animation

**Problem**
Tapping the X on the listing card makes it vanish instantly instead of sliding down with a smooth animation.

**Fix**
- Add an explicit animation tied to the card's visibility state so the slide-out transition always fires, even when the Map view interferes with the animation context.
- Remove the redundant duplicate transition (it's defined both on the card overlay itself and at the usage site) to keep things clean.
- The dismiss spring settings from the debug panel will continue to work.
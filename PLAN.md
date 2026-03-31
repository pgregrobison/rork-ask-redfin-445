# Fix map compass and scale bar visibility and positioning

**What's wrong now:**

- The scale bar never appears because it's missing the auto-visibility setting
- The compass is always visible because it's grouped with the scale and not responding to rotation
- Both controls are placed in the bottom-left corner together

**What will change:**

- **Scale bar** (bottom-left): Will appear temporarily when zooming in/out, then fade away — standard Apple Maps behavior
- **Compass** (bottom-right): Will only appear when the map is rotated away from north, then fade once the map returns to north — standard Apple Maps behavior
- Both controls will have the automatic visibility setting so they show/hide on their own
- The compass moves to the bottom-right corner, the scale stays in the bottom-left


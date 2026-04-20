# Make map shimmer a subtle 45° sweep line

**Change**

- Replace the current wide, bright shimmer band with a single soft diagonal line at 45°.
- The line is thin, low-opacity white, with feathered edges so it fades in and out rather than having a hard shape.
- It travels smoothly from off-screen on one corner to off-screen on the opposite corner, then loops seamlessly.
- Remove the overall white tint overlay so the map stays clearly visible underneath — only the moving line indicates loading.
- Keep the existing timing feel but slightly slower and eased for a calmer, more elegant motion.


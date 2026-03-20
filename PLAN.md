# Polish Tab Bar: Remove shimmer, fix FAB size, add symbol transitions

**Changes**

- **Remove shimmer ring** — Delete the `ShimmerRingModifier` and its extension entirely. The Ask Redfin FAB will be a clean circle with no animated ring.

- **Fix Ask Redfin FAB to true 62×62pt** — Reduce the sparkle icon size from 22pt down to 19pt (matching the tab bar icons), then keep the 62×62pt frame so the extra space becomes padding around the icon.

- **SF Symbol transitions on tab switch** — Use `.contentTransition(.symbolEffect(.replace))` on each tab icon so it animates smoothly when switching tabs. Selected tabs use the `.fill` variant of their icon (e.g. `heart.fill`, `house.fill`, `square.stack.fill`) while unselected tabs use the outline variant.
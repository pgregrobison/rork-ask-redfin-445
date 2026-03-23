# Rewrite pin selection animation with smooth centering

**What changes**

- **Smooth pan to selected pin**: When you tap a map pin, the map will smoothly and quickly animate to center on that pin using a snappy spring animation.
- **Offset for card overlay**: The pin will be positioned slightly above the true center of the screen, so it appears visually centered in the visible map area above the listing card that slides up from the bottom.
- **Keep current zoom**: The zoom level stays exactly where you left it — no zooming in or out on selection.
- **Deselect stays in place**: Tapping a selected pin to dismiss the card will not move the map at all.

**How it will feel**

- A fast, natural spring animation (similar to Apple Maps pin selection) pans the map into position.
- The pin lands in the upper portion of the visible map, perfectly accounting for the card overlay height.


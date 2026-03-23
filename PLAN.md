# Fix map card animation and smooth panning

**Two fixes:**

1. **Slide-up animation only on first pin selection** — When tapping a pin while another pin's card is already showing, the card content will crossfade to the new listing instead of sliding up from the bottom again. The slide-up animation will only play when going from no selection to a selection.

2. **Fix instant map snapping** — The map's "remember current region" callback can override an in-progress pan animation, causing the camera to snap. This will be fixed by briefly ignoring region updates while a pan animation is active, ensuring smooth panning every time.
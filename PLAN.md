# Fix map pan speed, card animation, and toolbar padding

**Three targeted fixes:**

### 1. Snappier map panning on pin select
- Remove the slow animated camera pan when tapping a pin — update the map position instantly (no `withAnimation` wrapper) so the map snaps to the selected pin's location immediately

### 2. Card animation only on appear/dismiss
- The listing preview card at the bottom of the map currently re-animates every time you switch between pins
- Change the animation so it only triggers when a card appears (no pin → pin selected) or disappears (pin selected → deselected)
- When switching between pins, the card content updates instantly without a spring animation

### 3. Remove extra padding from toolbar action buttons
- All toolbar buttons currently have an explicit 44×44 frame that adds unwanted spacing inside the native toolbar
- Remove these frames from all toolbar items across every screen (Find, For You, Saved, My Home, Ask Redfin) so the native toolbar handles sizing and spacing naturally
- Keep the icon font size and content shape for tap targets, just let the toolbar manage the layout

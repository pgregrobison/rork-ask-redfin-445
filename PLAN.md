# Deselect map pin immediately on dismiss

**What changes**

Right now, the map pin stays highlighted (red) during the entire card slide-out animation. The fix will make the pin deselect instantly the moment you tap the X button, while the card still slides out smoothly.

**How it works**

- A new internal property will hold the card data while it animates out, separate from the pin selection
- When you tap X: the pin unhighlights immediately, and the card begins sliding down
- After the slide-out finishes, the card data is cleaned up
- No visual change to the slide-out animation itself — just the pin reacts faster
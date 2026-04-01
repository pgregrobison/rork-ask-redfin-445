# Fix tap targets on map action buttons

**Problem**
The three stacked map action buttons (layers, draw, locate) have 44×44 frames, but the actual tappable area is smaller because the button style reduces hit testing to just the icon image, not the full frame.

**Fix**
- Add an explicit tap area shape (`.contentShape(Rectangle())`) to each button's label in the combined stack, ensuring the full 44×44 area is tappable
- Applied to both the standard and iOS 26 glass-effect variants of the stacked buttons
- No visual changes — only the interactive hit area is expanded
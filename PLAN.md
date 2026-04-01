# Fix pill selected state color & revert property type styling

**Bug fix — selected pill turns blue with black text:**

- The selected pill background uses the system accent color (blue), but the text color can glitch to black after interaction due to how SwiftUI resolves `systemBackground` in button contexts
- Fix by using `.white` for selected text and `.label` for the unselected text — this ensures contrast is always correct regardless of interaction state, in both light and dark mode

**Revert — Property Type section in the filter sheet:**

- Change the Property Type back from the cramped capsule pill row (6 items like "Multi-family" barely fit) to a wrapping chip/tag layout that gives each option enough room to breathe and be easily readable
- Each chip will have a rounded rectangle background, comfortable padding, and clear selected/unselected states

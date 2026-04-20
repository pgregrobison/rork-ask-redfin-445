# Shimmer loading over map during Realistic Mode thinking

**What will happen**

- While Realistic Mode is on and the chat is thinking/searching for homes, a shimmer effect will animate over the map on the Find tab.
- The shimmer will appear only when Realistic Mode is enabled AND the chat is in its thinking/searching state.
- It disappears the moment results arrive (or the user cancels), so the normal map returns instantly.

**Design**

- A soft, Apple-style shimmer sweep (pale gradient band moving diagonally across the map), layered above the map pins but below the chat sheet and overlay buttons.
- The shimmer uses a subtle white/translucent highlight with a gentle linear gradient, paired with a very light frosted tint so the map still feels alive underneath.
- Fade-in and fade-out are smooth (~0.25s) so toggling on/off doesn't feel jarring.
- Pin taps and map gestures are blocked while shimmering, signaling that results are being prepared.

**Where it shows**

- Find tab map view only (not the list view, not inside the chat itself).
- Active in both bi-directional and one-way sync modes — any time Realistic Mode is on and the chat is thinking or searching.

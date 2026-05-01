# Fix DP sheet drag vs scroll behavior (current + hybrid)

**Behavior**

- Tap a property to open the detail page. The sheet starts collapsed.
- Grab anywhere on the sheet (handle or content) and drag up — the sheet smoothly expands. Content scrolling is locked while collapsed.
- Once expanded:
  - Swiping up scrolls the detail page normally.
  - Swiping down from the top of the page begins dragging the sheet toward collapsed. Release past the halfway point (or with a fast downward flick) to snap collapsed; otherwise it springs back to expanded.
  - If you are scrolled down inside the page, swiping down only scrolls the page. When it reaches the top it stops there — you must lift your finger and grab again to drag the sheet down.
  - The drag handle always drags the sheet, regardless of scroll position.

**Where it applies**

- Current DP variant and Hybrid DP variant — same gesture rules in both.

**Feel**

- Sheet follows the finger 1:1 while dragging.
- Snap animation uses a soft spring.
- Light haptic tap on each snap (collapsed / expanded).

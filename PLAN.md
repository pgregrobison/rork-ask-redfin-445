# Make pulling the detail sheet down feel instant

**The problem**

When the property details panel is fully open and scrolled to the top, pulling down feels sticky. The list inside the panel keeps trying to bounce before the panel finally agrees to collapse, so there's a noticeable lag and resistance.

**The fix**

- Disable the inner list's rubber-band bounce while it's at the top, so a downward drag immediately moves the panel instead of stretching the list.
- Hand off the drag to the panel the moment the finger moves down at the top of the list — no activation delay — so closing mirrors the same instant feel as pulling up to expand.
- Keep upward drags fully scrolling the list as they do today.

**Result**

Pulling the panel down from the top will feel exactly like the inverse of pulling it up: one smooth, immediate motion that snaps closed with the same spring.
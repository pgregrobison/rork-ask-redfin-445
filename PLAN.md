# Rebuild detail page sheet so drag and scroll feel natural

## Why it feels broken today

The sheet currently runs two gestures at once: the scroll view is trying to scroll the content, and a custom drag is trying to move the sheet. iOS almost always lets the scroll view win, which is why pulling the sheet up, pulling it down, and the scrolled-down handoff all feel unreliable. The drag handle is also a tiny 5pt-tall capsule, which makes it hard to grab on purpose.

We'll keep the inline sheet (so it never covers the Ask Redfin input bar), but make it behave like the sheets in Apple Maps and Find My.

## What will change for you

- **Pulling the sheet up from collapsed**: anywhere on the sheet works — the handle, the address, the price, the whole top area. One smooth motion lifts it to expanded.
- **Pulling the sheet down from expanded**: when the content is scrolled to the top, swiping down anywhere on the sheet smoothly drags it toward collapsed. Past the midpoint (or with a flick), it snaps closed.
- **Scrolled down inside the expanded sheet**: swipe down only scrolls the content back up, exactly like a normal page. Once the content reaches the top, continuing to pull down seamlessly hands off and starts dragging the sheet — no lift-and-retry needed.
- **The drag handle is always grabbable**: even if the content is scrolled down, dragging directly on the handle pulls the sheet down. The handle itself becomes a much larger, easier-to-hit target (about three times taller hit area) while looking the same.
- **Snappier feel**: lighter haptic when the sheet locks into collapsed or expanded, and the spring is tuned so flicks resolve quickly instead of drifting.
- **Ask Redfin input stays put**: the floating Ask Redfin bar at the bottom remains visible and untouched in every state — collapsed, dragging, expanded, scrolled, and photo view.

## Where it applies

- The Current detail page
- The Hybrid detail page

Both will share the same interaction model so they feel identical.

## How it works under the hood (in plain terms)

Instead of two gestures fighting, the scroll view itself becomes the source of truth. When you pull the content past its top edge, that overscroll is converted into sheet movement. When you flick or release, the sheet snaps to collapsed or expanded based on distance and velocity. The drag handle keeps its own dedicated gesture so it always works, even mid-scroll.

No changes to layout, colors, content, or the Ask Redfin bar.
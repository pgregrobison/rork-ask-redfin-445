# Tighten drag handle and make sheet collapse the true inverse of expand

## What's wrong today
- The grab bar at the top of the detail sheet has a tall 44pt tap area, making it visually heavy.
- When the sheet is expanded and scrolled to the top, dragging down first tries to scroll the page, then "realizes" you wanted to collapse and snaps — that's the awkward delay you're feeling. It's because the collapse is triggered after you let go, based on overscroll, instead of dragging the sheet in real time.

## The fix

**Slimmer grab bar**
- Reduce the handle's tap area so the bar itself feels tighter and more refined, while still being easy to grab.

**Collapse becomes the exact inverse of expand**
- From the expanded state, if the content is scrolled to the very top, a downward swipe anywhere on the sheet immediately drags the sheet down in real time (1:1 with your finger), just like a pull-up from collapsed expands it 1:1.
- Release past the midpoint (or with a fast flick down) snaps to collapsed; otherwise it springs back to expanded.
- Once any downward drag has passed the handoff threshold, the inner page scroll stays locked for the rest of that gesture so there's no fight between scrolling and dragging.
- If the page is scrolled even slightly down, a downward swipe only scrolls the content — never drags the sheet. The sheet can only be collapsed by content drag when at scroll top, or by grabbing the handle directly (which always works).

**Result**
- Pull up → expand. Pull down from the top → collapse. Same feel, same responsiveness, no delay, no double-take.

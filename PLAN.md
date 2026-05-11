# Make expanded detail sheet easier to drag down when scrolled to top

**Problem**
When the property detail sheet is expanded and the inner content is scrolled all the way to the top, pulling the sheet down to collapse it often gets "eaten" by the scroll view, requiring a deliberate, large gesture before the sheet actually starts following the finger.

**Fix**
- Make the downward pull-to-collapse gesture take priority over the scroll view as soon as content is at the top, so the sheet starts moving with the very first downward pixel instead of after a 4‑pt threshold.
- Disable scroll bouncing at the top edge while expanded so the scroll view can't briefly steal the drag with a rubber-band.
- Apply the same change to both the standard listing detail sheet and the hybrid (map-style) detail sheet so behavior is consistent.
- Keep upward drags untouched — scrolling the content up still works exactly as before.

**Result**
From the fully scrolled-up state, a small downward swipe anywhere on the sheet immediately starts collapsing it, matching the feel of native Apple bottom sheets (Maps, Stocks).
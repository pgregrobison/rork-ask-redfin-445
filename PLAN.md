# Fix chat header gradient and content offset

Two targeted fixes in the Ask Redfin chat view:

**1. Soften the header gradient**
- Currently the gradient is fully opaque for 55% of its height, completely hiding text beneath it
- Change it to fade out much sooner — fully opaque only at the very top, then quickly transitioning to transparent so text is visible through most of the header area

**2. Fix the excessive top spacing**
- The chat content is pushed down ~100pt too far because there's both a large top content margin (76pt) and the header's safe area inset stacking together
- Remove the redundant top content margin so the chat content sits naturally just below the header
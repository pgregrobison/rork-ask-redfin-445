# Fix pin staying selected too long after card dismissal

**Problem:** After dismissing the map home card, the map pin stays highlighted/selected for about 1 extra second before deselecting.

**Fix:** Reduce the delay between the card sliding out and the pin deselecting. Currently the delay is ~0.875 seconds (way longer than the actual slide-out animation). Will reduce it to ~0.35 seconds to match the spring animation duration, so the pin deselects right as the card finishes sliding away.
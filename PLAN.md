# Fix sluggish map panning and zooming

**Problem**
- Every time you finish panning/zooming the map, the app redundantly re-sets the map position to the exact same spot, causing an extra render cycle that makes the map feel laggy and unresponsive.
- The user location tracker can also fight with manual panning, adding to the sluggishness.

**Changes**
1. **Stop re-assigning the map position after every pan** — Only save the current zoom level (span) when the map stops moving, without forcing the map to re-render to the same spot it's already at.
2. **Disable user-location tracking as soon as the user manually pans** — Prevent the location tracker from overriding user gestures and snapping the map back.
3. **Result**: Panning, zooming, and all map interactions will feel smooth and immediate with no delays or blocked actions.
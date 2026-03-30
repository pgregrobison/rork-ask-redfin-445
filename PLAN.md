# Fix user location dot jittering on map

**Problem**
The blue location dot on the map jitters because every tiny GPS coordinate change (even fractions of a meter) causes the dot's position to update and the map to potentially re-pan.

**Fix**
- Only update the stored user location when the new reading is more than ~10 meters away from the current one — this filters out GPS noise/drift
- This stabilizes both the dot position and prevents unnecessary map camera changes from the location watcher
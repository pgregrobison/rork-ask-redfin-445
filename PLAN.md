# Zoom map to fit both user location and selected Compass listing

When a Compass Coming Soon listing is selected (e.g. via notification tap), the map will smoothly zoom to show both your current location and the selected home in the visible area, instead of just panning to the home alone.

**What changes:**
- After selecting the nearest Compass listing, the map calculates a region that includes both your live location dot and the selected home pin
- The map smoothly animates to this fitted region with comfortable padding so both points are clearly visible
- If your location isn't available, it falls back to the current behavior of just panning to the listing
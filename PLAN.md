# Fix zoom on Compass Coming Soon notification tap

**Problem**
When tapping the Compass Coming Soon notification, the map pans to the listing but stays at the current zoom level (very zoomed out). It should zoom in tightly to show both your location and the selected listing.

**Root cause**
The notification handler finds the listing and calls a "select" action that only pans without changing zoom. The zoom-to-fit logic exists but isn't being used in this path.

**Fix**
- When the notification is tapped and the listing is found, use the zoom-to-fit behavior (same as the "show on map" feature) that tightly frames both your current location and the selected listing
- The listing will still be selected and the card will appear as before — just with proper zooming
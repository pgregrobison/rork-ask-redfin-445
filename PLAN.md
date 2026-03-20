# Persist map position & wire up locate button

**What's changing:**

### 1. Persist map position across view changes
- Save the map's camera position whenever you stop panning/zooming, so switching to list view, navigating to a listing detail, or changing tabs and coming back always returns you to where you left off
- The map already stores its position in memory — we just need to capture camera changes so user-driven pans are remembered

### 2. Wire up the "locate me" button
- Tapping the crosshair/location button on the map will request your current location and smoothly pan the map to it
- A new location service runs behind the scenes to handle permissions and fetch your GPS position
- The locate button icon updates to show a filled state when the map is centered on your location
- If location permission hasn't been granted yet, tapping the button will trigger the system permission prompt
- Adds the required location permission description: *"See homes near your current location"*

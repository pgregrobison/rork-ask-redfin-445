# Fix locate button to always pan to current location

**What's wrong:** Tapping the locate button only moves the map the first time. After that, if your location hasn't changed, nothing happens.

**Fix:** When you tap locate, the app will immediately move the map to your current location every time — even if it already knows where you are. It will also still request a fresh location update in case you've moved.
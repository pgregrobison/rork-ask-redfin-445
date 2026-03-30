# Remove delay between sheet close and map pan

**What changes:**

- Remove the 100ms wait after the Ask Redfin sheet closes before the map starts panning
- Start the map pan immediately as soon as the sheet finishes dismissing, so the two motions feel connected rather than sequential

This is a single-line change — removing the `Task.sleep` in the sheet's `onDismiss` callback so `fitListings` fires instantly.
# Filter "Show on Map" to only New York area homes

**What's happening now:**
- The "Show on map" button in Ask Redfin fits ALL matched listings on the map, including homes in Seattle, WA
- This causes the map to zoom out to country level to show both coasts

**What will change:**
- When "Show on map" is tapped, only New York area homes will be included
- The map will stay zoomed in to the New York metro area instead of zooming out to the entire country
- The filtering will happen in the listing cards view before passing listings to the map, so only NY-state homes are sent to the map fit function

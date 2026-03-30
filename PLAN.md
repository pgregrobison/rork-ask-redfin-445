# Update "Show on Map" to fit all chat result listings

**What changes**

- Tapping **"Show on map"** in Ask Redfin results will pan and zoom the map to fit **all** listings from the chat results, not just navigate to a single home.
- No individual listing card will be selected at the bottom — just all pins visible on the map.
- The map will have standard padding around the fitted region so pins aren't clipped at the edges.

**How it works**

1. A new function is added to the map logic that calculates a bounding region from a list of homes and smoothly animates the map to that region.
2. The "Show on map" action dismisses the chat, switches to the map tab, and calls this new fit-all function instead of selecting a single listing.

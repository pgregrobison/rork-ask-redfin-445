# Fix pin positioning when tapping a map annotation

**Problem**
Tapping a map pin moves the map so the pin ends up behind the home card overlay at the bottom of the screen. This is caused by the header offset being applied when it shouldn't be for single-pin selection.

**Fix**
- When tapping a pin to select it (no chat sheet visible), offset the map center **downward** so the pin appears above the card overlay, not behind it
- Remove the header top-offset from the single-pin pan since it pushes pins in the wrong direction for this use case
- Add a bottom offset to account for the card overlay height (~30% of screen), so the pin lands in the visible map area above the card
- The header offset will still be used in the multi-pin `fitListings` flow where it's needed
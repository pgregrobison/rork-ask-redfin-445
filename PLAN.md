# Account for header when fitting map pins

**What's changing**

When the map zooms to fit search result pins, some pins near the top of the screen can end up hidden behind the navigation bar and the location pill overlay. This update adds a top inset to the map fitting calculations so all pins remain comfortably visible below the header.

**Details**

- Add a top header fraction (accounting for the status bar, navigation bar, and the floating pill) to the `fitListings` and `panToListing` functions
- This works alongside the existing bottom sheet offset — pins will be positioned in the truly visible area between the header and the sheet
- The offset shifts the map center upward slightly so the topmost pin clears the header with comfortable padding

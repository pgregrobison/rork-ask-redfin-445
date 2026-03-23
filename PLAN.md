# Full-width map home card with device-matched corner radius

**Changes**

- **Card margins**: The map home card will have 8pt spacing on the left, right, and bottom edges of the screen (reduced from the current 16pt horizontal padding)
- **Corner radius**: The card's corner radius will be calculated from the device's own screen corner radius minus the 8pt inset, so the card's corners run concentrically with the device edges — this uses Apple's display corner radius API with `.continuous` corner curve for the squircle shape
- **Fallback**: On devices where the screen corner radius isn't available (e.g. older flat-screen devices), a sensible default (44pt) will be used
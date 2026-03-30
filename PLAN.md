# Allow map panning with selected home & fix zoom framing

**Two targeted fixes:**

1. **Allow map panning while a home card is shown** — Currently, a full-screen invisible overlay blocks all map gestures (pan, pinch, zoom) when a home is selected. This will be removed so you can freely interact with the map even with the card visible. Tapping the map background will still dismiss the card.

2. **Fix zoom to tightly frame user location + selected Compass listing** — The current zoom padding is too generous (1.6×), making both points appear far apart. This will be tightened and the center will be shifted slightly upward to account for the card at the bottom, ensuring both your location dot and the selected home pin are clearly visible in the map area above the card.
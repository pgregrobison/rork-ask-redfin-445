# Fix map home card close button, pin centering, and smooth panning

**Changes**

- **Glass close button with interaction animation**: Update the close (×) button on the map home card to use the interactive liquid glass style (with press animation feedback), matching the map action buttons
- **Center pin on true screen center**: Remove the vertical offset that pushes the pin above the home card — the pin will now center in the middle of the full screen when selected
- **Always smooth pin-to-pin panning**: Fix the issue where tapping from one pin to another sometimes snaps instantly — ensure every pan uses a smooth animation by preventing the map's camera-change callback from interrupting the animated position mid-flight
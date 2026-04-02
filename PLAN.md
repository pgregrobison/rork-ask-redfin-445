# Fade entire navigation bar (including glass background) during zoom transition

**Problem**
The toolbar icons fade in after the zoom transition, but the glass background "bubbles" of the navigation bar are visible the entire time, breaking the effect.

**Fix**
- Hide the navigation bar's glass/material background during the zoom transition (while the toolbar opacity is 0)
- Once the fade-in starts, switch the background to visible so it appears together with the icons
- This ensures the entire navigation bar — background and icons — fades in as one unit after the zoom transition completes

# Fix scroll-to-top reliability and input field line height

**Two changes:**

### 1. Reliable scroll-to-top on all devices
- **Problem:** The spacer height is measured dynamically from the scroll view, which reports different values on simulator vs. real iPhone (likely due to safe area differences in the sheet). This makes the spacer too short on device, so the message can't physically scroll far enough.
- **Fix:** Replace the dynamic `visibleHeight` measurement with a guaranteed-large spacer using the screen height. This ensures there's always more than enough room below the user message to scroll it all the way to the top, regardless of device or safe area differences.
- Remove the GeometryReader background that measures `visibleHeight` — it's no longer needed.

### 2. Input field line height
- **Problem:** The current line spacing and padding don't produce the exact 24pt-per-line layout requested.
- **Fix:** Set the vertical padding to 12pt (already in place), and use a combination of a minimum frame height of 24pt on the text field and line spacing of ~7pt (body font is ~17pt, so 24 − 17 = 7pt line spacing) to achieve 24pt per line of text. This yields 48pt for 1 line, 72pt for 2 lines, etc.
# Skip photo focus view when navigating back

**Problem**
When you navigate away from a home detail while the photo viewer is open, then press back, you land on the photo viewer instead of the home detail — adding an extra "back" tap.

**Fix**
- Automatically close the photo focus overlay whenever you leave a home's detail page
- This way, pressing back always returns to the home detail (with the info sheet), never the photo viewer
- No change to how the photo viewer works when you're actively using it
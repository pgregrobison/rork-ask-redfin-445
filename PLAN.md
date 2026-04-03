# Fix location pill tap by moving it above the navigation bar

**Problem**
The location + homes pill is visually positioned over the navigation bar (via a negative offset), but the system navigation bar intercepts all taps in that region, making the pill untappable.

**Fix**
- Move the location pill out of the Find screen and place it as an overlay on top of the entire navigation area in the main content view
- This ensures it truly sits above the navigation bar in the view hierarchy, so taps reach it
- The pill will remain in the exact same visual position — only its placement in the view hierarchy changes
- All existing behavior (morphing menu, location search, filters) stays the same
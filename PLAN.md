# Make location pill interactive above navigation bar

**What's happening:** The location + homes pill is visually positioned over the navigation bar but the toolbar intercepts all taps, making it non-interactive.

**Fix:** Add `.zIndex(1)` to the pill so it renders and receives touches above the navigation bar content in the ZStack.
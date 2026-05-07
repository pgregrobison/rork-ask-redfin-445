# Fix tour day notification tap

**Problem**

Tapping the fake tour day notification banner currently does nothing — the tap isn't reliably reaching the banner's tap handler because the overlay window's pass-through logic and the gesture setup don't play well together.

**Fix**

- Make the floating banner's tap area reliable: wrap the banner content in a proper button so taps always register, and keep the swipe-up-to-dismiss drag gesture working alongside it.
- Update the overlay window so it only intercepts touches that actually land on the banner pill, and lets every other tap pass straight through to the app underneath (so the rest of the app stays interactive while the banner is up).
- Keep the existing look, animation, auto-dismiss after 5 seconds, and the behavior that tapping it opens Ask Redfin and starts Tour Day.

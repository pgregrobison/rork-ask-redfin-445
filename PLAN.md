# Slide-down dismiss animation for map home card

**Change**

When tapping the close button on a map home card, the card will slide down off the screen (reversing the slide-up entrance animation) instead of fading out or disappearing abruptly.

**Details**

- The dismiss action will be wrapped in an explicit animation to ensure the slide-down transition plays smoothly
- The existing `.move(edge: .bottom)` transition already supports this — we just need to make sure the dismiss triggers within an animation context


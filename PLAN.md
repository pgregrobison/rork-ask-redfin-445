# Fix slow map panning and enlarge pin tap targets

**Issue 1: Slow map panning**
- The card appear/disappear animation is currently applied to the entire map + card container, which accidentally double-animates the map camera
- Move the animation so it only affects the listing card sliding in/out, leaving the map camera free to pan at its intended speed

**Issue 2: Larger pin tap targets**
- Add 2pt of extra tap area around every map pin so they're easier to tap, without changing the pin's visual size
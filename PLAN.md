# Refine Details Page Toolbar, Sheet Behavior & Photo Focus View

## Changes

### 2. Sheet Extends to Just Below Header

- Increase the sheet's maximum travel so it reaches just below the custom navigation header (roughly the safe area top + header height)
- When fully expanded, the sheet will stop right under the toolbar buttons, keeping them always accessible

### 3. Pull-Down-to-Collapse When Fully Expanded

- When the sheet is fully expanded and the scroll is at the top, dragging down anywhere on the sheet will collapse it back to its peek state
- This uses scroll position tracking: if the user is at the top of the scrollable content and pulls down, the gesture collapses the sheet instead of bouncing the scroll view
- When the sheet is not fully scrolled to top, normal scrolling behavior is preserved

### 4. Inline Focus Photo View (Not Full-Screen Cover)

- Replace the current full-screen cover photo viewer with an inline overlay that lives inside the details page
- Tapping a photo darkens the background with a smooth fade and transitions the photo to the center of the screen
- The same custom glass header (back → close, heart, share) and the same sticky footer ("Request showing" + sparkle button) remain visible throughout
- Swiping between photos horizontally is supported in the focused state
- Tapping the background or the close button exits focus mode, reversing the transition smoothly


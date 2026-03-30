# Prevent Ask Redfin header from collapsing into overflow menu

**Problem**
During certain interactions in the Ask Redfin chat (keyboard appearing, scrolling, voice mode), iOS automatically consolidates the toolbar items (thread dropdown + close button) into a single overflow "more" menu in the upper right.

**Fix**
- Force the navigation bar to always remain visible and stable by adding explicit toolbar visibility control
- Ensure the toolbar items maintain their placement regardless of keyboard state, scroll position, or voice mode transitions
- The dropdown menu on the left and close button on the right will always stay in place
# Improve Focus Photo Mode

**Changes**

- **Full black background**: The focus photo overlay will use solid black (#000000 at 100% opacity) instead of the current 85% opacity, so nothing from the detail page behind is visible.

- **Close button via native navigation**: Instead of tapping anywhere to dismiss, a close button (X icon) will appear in the upper-left of the navigation bar. The existing favorite and share actions in the upper-right will persist — same toolbar, just with an added close/dismiss button when in focus mode.

- **Sticky footer persists**: The same sticky footer ("Request showing" + sparkle button) remains visible during focus mode, layered on top of the black background.

- **Tap-to-dismiss removed**: Since we're adding a proper close button, tapping the black background will no longer dismiss the focus view. Swiping between photos still works as before.
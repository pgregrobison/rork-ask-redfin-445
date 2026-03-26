# Photo counter, focus nav fix, and red glass Request button

**Changes**

- **Photo counter in focus view** — A subtle "3 of 9" label appears just below the navigation header when viewing photos in focus mode, showing the current photo index out of total.

- **Replace back arrow with close button in focus mode** — When focus photo view is active, the system back button is hidden and replaced by the close (✕) button, so users can't accidentally back out of the entire detail page. Closing focus mode restores the normal back arrow.

- **Red glass "Request Showing" button** — The "Request showing" button in the sticky footer becomes a native Liquid Glass button with a red tint on iOS 26+, replacing the solid red background. On older iOS, it falls back to the current solid red style.
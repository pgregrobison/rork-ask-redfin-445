# Add photo/video attachment + button to Ask Redfin chat

## Features

- A glass-styled circular **+** action button appears to the left of the chat input only when the input is focused, sliding in smoothly.
- Tapping **+** opens a native iOS menu with three options: **Take Photo**, **Record Video**, **Choose from Library**.
- **Take Photo** and **Record Video** open the system camera; **Choose from Library** opens the photo picker (multi-select up to a few items).
- Selected media appears as thumbnail previews in a horizontal row directly above the input field, each with a small **×** to remove.
- The user can still type a caption alongside the attachments (or send with no text).
- The send button activates as soon as there's at least one attachment or text.
- Tapping send posts a chat message that displays the attached photos/videos as a clean image/video grid, with the caption underneath if present.
- Videos in the chat show a play indicator and tap to play inline.

## Design

- **+** button: 32pt circle with liquid-glass effect on iOS 26, ultra-thin material fallback otherwise, plus icon at medium weight, matching the existing input field's visual language.
- Smooth spring-in / fade-out as focus changes — the text field gracefully shifts right to make room.
- Attachment preview row: rounded thumbnails (~64pt) with subtle shadow, video thumbs show a play glyph overlay; remove badge sits at the top-right corner.
- Native iOS share-sheet-style menu — no custom UI, just the standard system menu attached to the + button.
- In-chat attachments: rounded image grid (1 image full width, 2 side-by-side, 3+ in a 2-column grid) with consistent corner radius matching message bubbles.

## Screens

- **Ask Redfin chat**: gains the new + button, attachment preview tray, and updated user message bubbles capable of displaying photo/video grids with optional caption text.

## Notes

- Camera will show the standard "install on device" placeholder in the cloud simulator (real camera works on device); the photo library picker works in the simulator with sample photos.
- Required permissions (camera, microphone for video, photo library) will be added so the pickers function on real devices.

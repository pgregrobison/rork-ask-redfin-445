# Design pass on the James detail page style

## Changes

### 1. Primary buttons — black in light mode, white in dark mode
- The "Request showing", "Estimate my rate", "Estimate my payment & rate", and other filled buttons will use the system primary color (black/white) instead of the red brand color
- Brand red stays as the accent for links, text highlights, and secondary elements (like "Continue reading")

### 2. All buttons fully rounded
- All buttons (filled and outlined) get a capsule/pill shape instead of the current 10pt corner radius
- This applies to: "Estimate my rate", "Request showing", "Full property details", "Estimate my payment & rate", "Tour in person", "Tour via video chat", "Let's chat", and the action circle buttons

### 3. Taller photo section — 40% of screen height
- The hero photo carousel height changes from the current fixed 340pt to 40% of the screen height (roughly 346pt on iPhone 15 Pro, scales with device)

### 4. Segmented control with liquid glass over the photo
- A native iOS segmented picker with 4 segments: **Media**, **Map**, **3D**, **Street**
- Positioned at the bottom of the photo container, inset 16pt from the left, right, and bottom edges
- Height of 40pt
- Uses liquid glass styling on iOS 26+, falls back to standard segmented style on older versions
- Only "Media" is functional (shows the photo carousel); the other tabs are visual placeholders for now

### 5. Carousel dots moved above the segmented control
- The native page indicator dots move from the default bottom position to sit 8pt above the top edge of the segmented control
- This creates a clear visual stack: photos → dots → segmented control at the bottom of the photo area

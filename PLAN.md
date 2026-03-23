# Replace slow map panning with instant, interruptible transitions

**Problem**
The current pin-tap animation uses a SwiftUI spring animation wrapper that locks the map during the transition, preventing rapid tapping and making everything feel sluggish.

**Fix**
- Remove the blocking animation wrapper and the "is panning" lock flag entirely
- Set the map camera position directly when a pin is tapped — MapKit's built-in Map view already smoothly animates between positions on its own
- This means every new pin tap instantly interrupts and redirects the camera, so rapid tapping feels snappy and responsive
- No artificial delays or cooldowns — the map stays fully interactive at all times
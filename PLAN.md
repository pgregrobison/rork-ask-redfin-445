# Fix debug animation controls for map camera movement

**Problem**
The map camera pan animation ignores the debug slider values because SwiftUI's `Map` doesn't respect `withAnimation` timing parameters — it always uses its own fixed internal animation for camera movement.

**Fix**
- Replace the `withAnimation` approach for map camera panning with MapKit's native `MKMapView.animate` via a `UIViewRepresentable` wrapper, which gives direct control over animation duration and spring parameters
- Alternatively, use a step-based camera interpolation with `Timer`/`DisplayLink` so the debug sliders actually control how long and how bouncy the pan feels
- Ensure the overlay card and dismiss animations are also properly wired (these should already work since they're pure SwiftUI)

**What you'll notice after the fix**
- Changing the pan duration slider will visibly slow down or speed up the map camera movement when tapping a pin
- Toggling spring mode and adjusting response/damping will change how the camera settles into position
- Overlay and dismiss spring sliders will also work as expected

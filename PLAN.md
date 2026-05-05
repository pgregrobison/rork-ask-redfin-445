# Fix immediate crash: remove broken map-pan minimize hack

**Why the app crashes**
The last attempt to trigger the minimized accessory bar on map pan reassigned and re-parented an internal scroll view gesture recognizer. iOS treats that as an unsupported operation and crashes on launch.

**What I'll do**
- Remove the broken hidden-scroll-view driver and its hooks from the map view and view model so the app launches cleanly again.
- Restore the previous behavior where the accessory minimizes on tab-bar's native scroll-down behavior plus card visibility.
- Leave list view, other tabs, and all unrelated screens untouched.

**After this fix**
The app will launch normally. The "minimize accessory when panning the map" behavior will be **not yet implemented** — I'll need a fresh, safer approach (e.g. a transparent scroll layer on top of the map that passes taps through). Happy to try that next once the crash is resolved.
# Simplify debug panel — remove DP style and animation tuning

## Cleanup

- Remove the **DP Style** picker entirely. The detail page will always use the Hybrid layout.
- Remove the **Camera Pan**, **Card Overlay Entrance**, and **Card Overlay Dismiss** sections from the debug panel.
- Remove the **Reset Animation Defaults** button.
- The detail-page-style setting (and its enum) is deleted; references to "Current" and "James" layouts are no longer reachable from the debug panel.
- Pin pan and card slide-up/down animations now use sensible fixed defaults instead of being user-tunable.

## What remains in the debug panel

- Global Entrypoint (App nav vs Accessory)
- Search Behavior (Default vs Map Focus)
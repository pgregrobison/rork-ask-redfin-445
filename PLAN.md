# Clean up debug panel: lock in zoom + hybrid, remove realistic mode and transition options

**What changes**

- Remove the "Card Transition" section from the debug panel — every variant now uses the zoom card transition by default.
- Remove the "Realistic Mode" section (and its bi-directional / one-way sync sub-options) entirely from the debug panel.
- Set the default detail page style to "Hybrid" so all variants use the hybrid layout out of the box.
- Wire the rest of the app so zoom transitions are always on, and any realistic-mode-only behavior (8-second thinking stretch, live chat→map sync gating) is simply turned off.
- Clean up the underlying settings model so the removed options no longer linger as stored preferences.

**What stays**

- Global Entrypoint (App nav / Accessory)
- DP Style (Current / James / Hybrid — defaulting to Hybrid)
- Search Behavior (Default / Map Focus)
- Camera Pan, Card Overlay Entrance, Card Overlay Dismiss animation tuners
- Reset Animation Defaults button
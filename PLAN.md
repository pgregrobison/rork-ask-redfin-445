# Add map animation tuning sliders to Debug Panel

**Features**
- New "Map Pin Animation" section in the Debug Panel with live-adjustable sliders
- Sliders for the **map camera pan** animation: duration, and an option to switch between ease-in-out and spring
- Sliders for the **card overlay entrance** spring animation: response and damping fraction
- Sliders for the **card overlay dismiss** spring animation: response and damping fraction
- Current values displayed next to each slider for precision
- All values persist across app launches so you don't lose your tuning
- A "Reset to Defaults" button to snap everything back to the original values

**Design**
- Matches the existing Debug Panel style — standard List sections with sliders
- Each slider shows its current numeric value inline
- Grouped into clear sub-sections: "Camera Pan" and "Card Overlay"

**Slider Ranges**
- **Pan duration**: 0.1 – 1.0s (default 0.35)
- **Overlay spring response**: 0.1 – 1.0s (default 0.35)
- **Overlay spring damping**: 0.1 – 1.0 (default 0.8)
- **Dismiss spring response**: 0.1 – 1.0s (default 0.35)
- **Dismiss spring damping**: 0.1 – 1.0 (default 0.8)
# Delete splash screen and tighten map controls alignment

**Splash screen**
- Remove the secondary "splash" state entirely. The app will go straight from the system launch screen (red background + logo) into the main app, with no second logo animation in between.

**Map controls alignment (accessory variant)**
- The map action buttons currently sit slightly below the list/map toggle in the navigation bar. This is caused by the glass-effect container adding a small internal margin around the stack.
- Increase the upward shift so the first action button lines up exactly with the toolbar icon's vertical center, matching it pixel-for-pixel.

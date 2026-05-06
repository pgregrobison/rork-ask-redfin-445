# Polish Tour Day: real notification, system colors, native button, tap-to-detail

Refining the Tour Day flow based on your feedback.

**Notification**
- Replace the styled in-app banner with a real local notification (same approach as the Compass nudge): when you type "tour day", a system notification fires after about 3 seconds with the welcome copy.
- Tapping the notification opens Ask Redfin and switches to the new Tour Day thread.
- Removes the floating welcome card overlay entirely.

**Colors**
- Buttons, icons, and text in the Tour Day UI default to the system primary color (white in dark mode, black in light mode) — affects the route widget header icon, "Open directions" button, and stop card numbers.
- Map pins and the route polyline stay brand red so they remain visible on the map.

**"Open directions" button**
- Reuses the same primary pill style as the existing "Show on map" button for consistency.
- The Apple Maps / Google Maps confirmation dialog now spawns from the button itself (not the map), keeping the choice attached to the action that triggered it.

**Tapping a stop**
- Tapping any numbered stop in the route widget's stop list opens that home's detail page and dismisses the chat sheet, so you land directly on the listing.
- The map preview still expands to fullscreen on tap (unchanged).

**What stays the same**
- Voice mode, route map widget layout, per-stop cards, and the wrap-up summary all behave as before.
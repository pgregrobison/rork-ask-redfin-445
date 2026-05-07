# Make the tour day notification look like a real iOS notification

**What changes**

- Restyle the fake "Welcome to tour day!" notification so it visually matches a real iOS push notification — same proportions, spacing, blur, corner radius, typography hierarchy, and subtle shadow.
- Position it at the top of the screen just under the Dynamic Island / status bar (where real iOS notifications land), centered with the standard side margins.
- Swap the icon for the actual Ask Redfin app icon (rounded squircle), matching the real notification icon size.
- Keep behavior identical: tap opens Ask Redfin and starts tour day, swipe up to dismiss, auto-dismisses after 5 seconds.
- Add the standard tiny entrance bounce so it slides down and settles like the real thing.

**No backend / notification system changes** — it remains a purely visual, in-app simulated banner.
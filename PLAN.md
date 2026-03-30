# Restyle custom header to match native navigation bar

**What changes**

The custom header bar in Ask Redfin will be restyled to perfectly match the native iOS navigation bar appearance:

- **Height**: Match the standard 44pt navigation bar content height, with proper top safe-area respect
- **Close button**: Wrapped in a glass effect circle (matching the `GlassActionButton` style used elsewhere in the app) — liquid glass on iOS 26, ultra-thin material fallback on older iOS
- **Thread switcher dropdown**: Wrapped in a glass effect capsule/pill background — same liquid glass treatment, giving it the native toolbar-item feel
- **Padding**: Standard 16pt horizontal padding, vertically centered content matching native nav bar spacing
- **No separator line** at the bottom — clean look as requested

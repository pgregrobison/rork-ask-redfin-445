# Use chevron.down back icon when zoom transition is active


**Change**

When the "Zoom" card transition is selected in debug settings, the back button on both detail page styles (Current and James) will show a **down chevron** (↓) instead of the default back chevron (←). This better aligns with the zoom dismiss gesture direction.

- The back button keeps its native toolbar placement and styling — only the icon changes
- Tapping it still dismisses the detail page as normal
- When "Native Push" transition is selected, the standard system back button appears as usual

**What's touched**

- Pass the transition style from the main screen into both detail page variants
- On each detail page, when zoom is active: hide the system back button, show a custom toolbar button with `chevron.down` that dismisses the view

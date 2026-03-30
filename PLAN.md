# Restore original NavigationStack header and prevent toolbar collapse

**Problem**
The current custom VStack header doesn't look right. You want the original system NavigationStack toolbar header back (dropdown on the left, close on the right), but it needs to never collapse into a "more" overflow menu.

**Fix**
- Restore the original `NavigationStack` with system toolbar items (thread switcher dropdown on the left, X close button on the right)
- Prevent the toolbar collapse by overriding the horizontal size class to `.regular` on the NavigationStack — this tells iOS there's enough room to always show all toolbar items, stopping the automatic collapse into a "more" menu
- The size class override is scoped only to the toolbar layout calculation, so the rest of the sheet content behaves normally
- The header will always show the dropdown and close button in their original positions
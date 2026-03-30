# Replace system toolbar with custom header to prevent collapse

**Problem**
The Ask Redfin sheet header sometimes collapses the dropdown and close button into a system "more" menu. This is an iOS behavior that can't be reliably prevented with system toolbar modifiers.

**Fix**
- Remove the system navigation bar and toolbar entirely from the Ask Redfin sheet
- Build a custom header row at the top of the view with the thread switcher dropdown on the left and the X close button on the right
- This custom header is just a regular view — iOS cannot collapse or rearrange it
- The look and feel will remain identical (same fonts, icons, spacing)
# Fix Ask Redfin header so it never collapses

**Problem**
SwiftUI's built-in toolbar sometimes auto-collapses the dropdown and close button into a single "more" menu. This is unpredictable and breaks the expected layout.

**Fix**
Replace the system toolbar with a custom, hand-built header bar that sits at the top of the sheet. Since it's just a regular view (not a toolbar), it can never be collapsed or rearranged by the system.

**What the header will always show**
- **Left side:** Thread switcher dropdown — shows current thread title with a chevron; tapping opens a menu listing all chat threads (with a checkmark on the active one) and a "New Chat" action
- **Right side:** Close button (X icon) — always visible, always tappable, always in the same spot

**How it works**
- Remove the `NavigationStack` wrapper and `.toolbar` from Ask Redfin entirely — this eliminates the system navigation bar that causes the collapsing
- Add a fixed custom header row at the top of the view instead
- The rest of the layout (messages, input bar) stays exactly as it is today

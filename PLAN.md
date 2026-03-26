# Overlay action buttons on chat input field

**What changes:**

- Convert the input bar from an `HStack` layout (text field + buttons side by side) to an **overlay** layout where action buttons float over the input field
- The text field fills the full width of the input bar, with right padding (~54pt) to keep text from running under the button
- The send button (and future voice button, stop button) is positioned as an `.overlay(alignment: .bottomTrailing)` on the input background, anchored to the bottom-right
- As the text field grows in height (multi-line), the button stays pinned to the bottom-right corner
- No visual or sizing changes to the buttons themselves — they remain 44×44 with the same styling

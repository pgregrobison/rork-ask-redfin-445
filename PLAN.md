# Chat input glass effect, adaptive buttons, tour scheduler spacing & input focus

## Changes

### 1. Floating glass chat input
- Remove the solid background behind the chat input bar
- Apply a liquid glass effect to the input field so it floats transparently over the chat messages
- On older devices, fall back to a frosted material background
- The message list will extend behind the input area for the floating effect

### 2. Adaptive button style
- "Continue" and "Request Tour" buttons in the tour scheduler will use **black background with white text** in light mode, and **white background with black text** in dark mode
- This replaces the current always-dark button style

### 3. Tour scheduler step spacing
- Add visible vertical gaps between each step in the tour scheduler (day → time → info) so the sections feel less cramped and each step has more breathing room

### 4. Tour scheduler input improvements
- When selecting an autofill suggestion in the Full Name field, automatically focus the Phone Number field
- The keyboard shows a blue **Next** arrow on the Full Name field to jump to Phone Number
- The Phone Number field shows a **Done** key to dismiss the keyboard

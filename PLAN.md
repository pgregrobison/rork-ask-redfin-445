# In-Chat Tour Scheduling Flow

## Features

- **Tour intent detection** — Typing anything like "tour", "tour a home", "tour this home", "schedule a tour", etc. triggers the tour scheduling flow
- **3-step expanding card** — A single inline widget appears in the chat that walks through 3 steps:
  1. **Pick a day** using a native iOS calendar-style date picker
  2. **Pick a time** using a native iOS wheel/dial time picker
  3. **Enter your name and phone number** with standard text fields
- **Step progression** — Completed steps collapse into a compact summary row; the next step expands open. Users can tap a completed step to go back and edit it.
- **Bot intro message** — The bot first replies with a short text message (e.g. "Let's get you scheduled!"), then the tour widget appears below it
- **Compact confirmation** — After submitting, the entire card collapses into a small confirmation summary showing the selected date, time, and name
- **Reusable pattern** — The step-based expanding card architecture is built to be reused for future in-chat flows (mortgage, offer submission, etc.)

## Design

- The widget card has a subtle secondary background with rounded corners, matching the existing chat card style
- Each step has a numbered circle indicator and a title row
- Completed steps show a checkmark and a single-line summary (e.g. "Saturday, Mar 29")
- The active step smoothly expands with a spring animation
- Native `DatePicker` in `.graphical` style for the calendar
- Native `DatePicker` in `.wheel` style for the time picker
- A "Continue" button at the bottom of each step advances to the next
- The final step has a "Request Tour" button that triggers the collapse into a confirmation
- Confirmation shows a green checkmark icon with date, time, and a "We'll confirm shortly" note
- Haptic feedback on step transitions and confirmation
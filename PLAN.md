# Add "Realistic Mode" with bi-directional vs one-way sync to the debug panel

## New debug section: Realistic Mode

Adds a new section to the debug panel (below "Search Behavior") for testing how chat and the Find page should interact.

### Features

- **Realistic Mode toggle** — off by default. When off, the app behaves exactly as it does today (fast thinking, no auto-context passing).
- When **on**, two things happen:
  1. Home-search thinking time is stretched to **8 seconds** so the flow feels closer to a real search.
  2. A sub-picker appears with two sync options:
    - **Bi-directional sync** — Entering chat passes the current Find context (map location + filters). After chat finishes thinking and produces listing results (post 8s), the Find surface's map + list are automatically updated to those results. No explicit "Show on map" tap needed.
    - **One-way sync** — Entering chat passes the current Find context (map location + filters) so chat builds on it. The Find surface does **not** auto-update. The user must tap **Show on map** on a chat result card, which then replaces Find's filters/results with the chat criteria and closes the chat.

### Design

- New section titled **"Realistic Mode"** appears directly below the existing "Search Behavior" section.
- Top row: a single toggle switch labeled *Realistic Mode*, with footer text explaining the 8s thinking delay.
- When toggled on, two selectable rows slide in below with checkmark-style selection (matching the existing debug panel style):
  - *Bi-directional sync* — subtitle: "Chat updates the map and list live as results arrive"
  - *One-way sync* — subtitle: "Chat only updates Find when you tap Show on map"
- No changes to visuals outside the debug panel; behavior changes apply quietly in the background.

### Behavior details

- **Thinking time**: When Realistic Mode is on, home-search requests use an 8-second minimum thinking duration instead of the current shorter randomized timing. Non-search chats are unaffected.
- **Context into chat (both modes)**: When the user opens chat from Find, the current map viewport/location and applied filters are passed in as starting context for the conversation.
- **Bi-directional**: Once chat produces a listing result set, Find's map pins and list are replaced with those listings automatically. The "Show on map" button still works but becomes redundant.
- **One-way**: Find never auto-updates from chat. "Show on map" replaces Find's filters and results with the chat's criteria and dismisses the chat sheet.
- **No visible context indicator** inside chat for now — the context is passed silently.

### Scope

- Debug-only. No production UI changes. All behavior gated behind the Realistic Mode toggle so the current default experience is untouched when the toggle is off.


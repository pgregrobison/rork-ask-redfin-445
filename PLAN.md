# Slack-style expanding menu that morphs from the location pill

**What changes**

The location menu on the Find page will be redesigned to mimic Slack's expanding toolbar menu behavior.

**How it works now**
- Tapping the location pill opens a floating panel below the toolbar with a dark overlay behind it

**How it will work**

- **Morph animation**: Tapping the location pill causes it to expand outward, growing from its pill shape into a full-width rounded card that covers the entire navigation bar area and extends downward
- **No background dimming**: The content behind (map or list) stays fully visible — no dark overlay
- **Close behavior**: An X button in the top-left corner of the expanded card, plus tapping anywhere outside the card dismisses it
- **Expanded card contents** (top to bottom):
  - Header row: X close button on the left, location name + home count on the right
  - Location search input field showing the current location
  - Search suggestions list (appears when typing)
  - Divider
  - Action buttons row: Filter, Save Search (same as today, just inside the expanded card)
- **Smooth spring animation**: The card morphs from the small pill size/position to the full card size, creating a fluid expansion effect
- **Toolbar hidden when open**: The map/list toggle and profile button are hidden behind the expanded card — only the card is visible at the top of the screen

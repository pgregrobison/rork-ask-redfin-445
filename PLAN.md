# Persist map position across view switches

**The problem**

Right now, switching between the map and list views in Find sometimes shifts the map to a different position, even when nothing should have moved it. The map should feel "sticky" — wherever you left it, that's where you come back to.

**What will change**

The map will only move in these specific situations:
- You drag, pinch, or zoom the map yourself
- You tap a pin (still auto-centers on the selected home, as today)
- You tap "Show on Map" from Ask Redfin
- An Ask Redfin search runs while you're on the map-focus variant
- You tap the "locate me" button to jump to your current location

In every other case — including switching to list and back, opening/closing details, dismissing the chat without a search, or running an Ask Redfin search on the accessory/list-focus variants — the map will stay exactly where you left it.

**How it'll feel**

Switching from map → list → map will be seamless: same center, same zoom, same area. No surprise jumps. Searches and filters that don't explicitly target the map won't disturb your view.
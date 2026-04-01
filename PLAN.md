# Fix location menu: morph pill in-place, position over toolbar, left-align text

**Issue 1 — Pill should morph into the menu (not fade/swap)**
- Remove the location pill from the toolbar entirely
- Place a single element as an overlay at the toolbar level that IS the pill when collapsed and IS the expanded menu when open
- When tapped, this single element animates its width, height, corner radius, and content to grow from a small centered capsule into the full-width menu card — no fading, no separate elements

**Issue 2 — Menu positioned over the toolbar**
- The expanded menu will sit directly on top of the toolbar row, covering the map/list toggle and profile button
- The toolbar items stay in place (no opacity changes) — they're simply behind the menu in z-order
- The menu's top edge aligns with the toolbar's top edge so it feels inline

**Issue 3 — Left-align text when expanded**
- When the menu opens, "Manhattan" and "18 homes" will left-align properly as a leading-aligned VStack
- The subtitle ("18 homes") will align to the leading edge of the title, not centered beneath it

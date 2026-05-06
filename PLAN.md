# Redesign the Neighborhood market section to match the new mockup

## What changes

Replace the current "Neighborhood market" block on the **My Home** tab with a cleaner, card‑based layout that matches the mockup. No other tab or section is touched.

## New layout (top to bottom)

- **Section title** renamed to **"Neighborhood"**.
- **2 × 2 grid of stat cards**, each with a small label, a chevron, a large value, and a secondary line:
  - Sale activity — 10 — Recently sold homes
  - Ave. home value — $260K — −9.6% since last month
  - Avg sale‑to‑list — 100% — +0.5% since last month
  - Redfin estimate — $336K — −9.6% since last month
- **Neighborhood developments** card containing:
  - Header row "Neighborhood developments" with a chevron.
  - Two development rows (Costco Wholesale — Under construction, Opening Spring 2026, "+3‑5% property value"; Highway 75 upgrade — Planned, "Lane additions to reduce congestion") each with a small isometric thumbnail and a chevron.
  - A subtle sparkle row at the bottom: **"How does this affect my home value?"**
- **Bottom row** (side by side): the existing **Similar homes** photo card ($411,000, 103 Bird's Cove Dr.) next to a new **Est. time to sell** stat card showing "27 days" with a green up‑arrow and "Faster than last month".

## Design details

- Uses the same theme/system colors as the rest of the page (adaptive light/dark) — the new cards inherit the same surface, border, and inset tokens already used elsewhere on this page.
- Stat cards reuse the typography scale already established (large bold value, small label, secondary trend line) so they feel native to the page.
- Development rows use a generated isometric construction illustration (one asset reused for both rows) on a tinted thumbnail.
- Sparkle CTA uses the existing red sparkle accent already used elsewhere in the app.
- Top hero cards, Open to Offers, and the Guide section are **not** changed.

## Out of scope

- No backend, no real data — values are hardcoded to match the mock.
- No interaction wiring beyond visual chevrons (taps remain inert, matching the rest of this page).


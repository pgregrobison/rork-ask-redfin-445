# Restyle the expanded Find sheet and add a sale-status segmented control

## What changes

**Expanded "Find" sheet (the panel that drops down with location, price, beds, baths)**

- **New status segmented control at the very top** (above the location search field):
  - Three options: **For Sale**, **For Rent**, **Sold**
  - No label above it — the control speaks for itself
  - Defaults to **For Sale**
  - Selected segment uses an inverse fill: dark in light mode, white in dark mode (matches the mock); unselected segments sit on a subtle neutral track
  - Tapping a segment updates the listings shown
  - This control is independent — it does **not** alter the existing Home Type control inside the Filter menu

- **Restyled controls** to match the mock and use shared design tokens (system colors, theme spacing, theme corner radii):
  - Price min/max dropdowns: cleaner pill buttons with consistent height, spacing, and a refined chevron
  - Beds and Baths pill rows: tighter, more uniform pills; selected pill uses the same inverse fill treatment as the new status control for visual consistency
  - Location search field, dividers, and action buttons (Filter, Save Search) tuned to the same spacing and radius scale

- **No change** to the collapsed pill, the Filter sheet, or the Home Type control inside Filter.

## Visual feel

- Calm, tightly aligned rows with breathing room that matches the mock
- A single accent treatment (inverse fill) used consistently for any "selected" state across status, beds, and baths
- All paddings, radii, and colors flow from the existing theme so light and dark modes both look intentional
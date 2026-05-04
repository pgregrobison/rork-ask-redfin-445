# Add location and more filters to the Filters menu

## What changes in the Filters menu

**Add Location at the top** (just under the For sale / For rent / Sold segmented control)
- Same look as the expanded Find panel: a rounded fill text field with a clear (×) button
- Live location suggestions appear in a dropdown list as you type, matching the expanded panel exactly
- Tapping a suggestion sets the location and dismisses the suggestions

**Add new filter sections below Home type** (in this order, all using the same theme colors, spacing, corner radius, and control styling as the rest of the sheet):

1. **Square feet** — two dropdowns side-by-side (Min sq ft – Max sq ft)
2. **Lot size** — two dropdowns side-by-side (Min – Max, in acres / sq ft)
3. **Year built** — two dropdowns side-by-side (Min year – Max year)
4. **HOA fee** — single dropdown (No HOA fee / up to $50 / $100 / $200 / $500 / Any)
5. **Parking spots** — tile selector row (Any, 1+, 2+, 3+, 4+) matching the Beds/Baths style
6. **More** — wrapping chips that toggle on/off: Pool, Garage, A/C, Fireplace, Waterfront. Selected chips use the dark inverse fill, unselected use the light fill — same as Home type tiles.

These are visual-only; tapping them updates local state so they feel real but they don't filter the listings.

**Reset button** also clears the new fake filter values so the sheet always returns to a clean state.

## Visual consistency

- All new controls reuse the existing 44pt control height, 48pt tile height, 12pt corner radius, and Theme spacing
- Dropdowns use the same Menu-with-chevron pattern already used for Price
- Chips and tiles use the same selected/unselected treatment (label color inverse, fill background)
- Section labels use the same subheadline style

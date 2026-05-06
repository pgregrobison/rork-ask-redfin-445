# Dark mode pass on My Home + new Neighborhood Market & Reimagine assets

**Scope:** My Home tab only. Hero carousel cards (the three colored value/equity/seasonal cards) are left untouched — their hardcoded colors stay.

## Dark mode color pass

- **Page background**: warm off-white (#FAF9F8) in light mode, automatically swaps to standard system dark in dark mode.
- **Address row, section headlines, body copy**: switch hardcoded near-blacks and greys to the system primary/secondary text colors so they stay readable in dark mode.
- **Cards** (Neighborhood Market container, Open to Offers dashboard, Conservative variant, Guide tip cards, Pro rows, stat chips, stat tiles): white card backgrounds become an adaptive card surface; hardcoded grey borders become the system separator color.
- **Sentiment rows, "Take the next step" button, outline buttons, "Reset" toolbar item, the orange/red/teal/green accents**: kept as-is per your selection (text + backgrounds only, accents preserved).
- **Stat chip inner background, stat tile insets**: switch to the existing adaptive inset color so they read correctly in both modes.
- **Map preview gradient overlay**: already uses systemBackground — verified, no change.

## Neighborhood Market asset

- Replace the hand-drawn Canvas gauge with a polished generated illustration: a clean, flat, balanced-market dial with the needle centered between "Buyer's market" and "Seller's market", using Redfin teal/green accents on a neutral background.
- Two versions generated — one for light mode, one for dark mode — and the right one is shown automatically.
- Sits in the same spot inside the Neighborhood Market card with the existing "Buyer's / Balanced / Seller's" caption row underneath.

## Reimagine Your Space asset

- Replace the gradient-and-icon placeholder with a generated editorial illustration showing a soft before/after room interior (subtle split / wand-and-stars motif) consistent with the flat, minimal Redfin look.
- Light + dark variants generated and swapped automatically.
- Same rounded card frame and "Get started" button below.

## Out of scope

- Hero carousel (3 colored cards) — untouched.
- Other tabs, debug panel, Find/list views — untouched.

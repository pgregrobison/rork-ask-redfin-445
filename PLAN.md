# Redesign My Home tab with hero carousel, market insights, Open to Offers, and home guide

Replace the current "My Home" tab with the richer design from the provided file. All other tabs and pages remain untouched.

## What you'll see on the My Home tab

- **Sticky address header** at the top showing a small home thumbnail next to "1223 Smith St" (same example address as before).
- **Native large nav title** ("My Home") with a profile icon in the top-right (unchanged behavior — opens the debug panel).
- **Hero carousel** — three swipeable colored cards:
  - Home value ($346,500, "Rising due to nearby sales") in deep green
  - Estimated home equity ($43,200, "Positive movement") in teal
  - Seasonal reminder ("Your home, fresh for spring.") in purple
  - Animated pill page indicator below.
- **Neighborhood market** section — white card with "Seattle is a balanced market" headline, a market gauge graphic, and a horizontally-scrolling row of stat chips (median list/sale price, days on market, recently sold). Below: two photo tiles for "Sold homes" ($411,000) and "Listed homes" (11 nearby).
- **Open to Offers** section — defaults to the "aggressive" variant: a map preview (380pt tall) with a red "Open my home to offers" CTA and supporting subtext. (Conservative variant and active dashboard variant are stubbed in but the default state shows the aggressive map CTA.)
- **A guide for your home** section — heading + subtitle, a horizontally-scrolling row of tip cards (clean dryer vent, HVAC filter, roof inspection, window seals), a "Reimagine your space" image card with "Get started" button, three "Work with a local pro" rows (lawn care, tree trimming, gutter cleaning), and a "Search projects" button.

## Notes on this first pass

- Missing pieces that the current code doesn't have yet (the offers setup flow, next-steps sheet, offers list sheet, animated map with pins, three-dots loader, draft state, market gauge image, reimagine image) will be added as **lightweight stubs** — minimal placeholder views/objects so the screen compiles and looks right in its default state. Tapping into those flows will open simple placeholder sheets for now.
- All photos and the home thumbnail use online image URLs (Unsplash). The market gauge and reimagine illustrations use simple placeholder graphics until you provide real assets.
- The screen launches in its default "aggressive" state (map CTA visible, no active listing, no draft) — exactly what you'll see on first load.
- No other tab, view, or behavior is touched.

## Next step after approval

Once approved I'll wire it in, run the build, and fix anything that doesn't compile. Then you can tell me which stubbed pieces (e.g. the animated offers map, the setup flow) you want fleshed out next.
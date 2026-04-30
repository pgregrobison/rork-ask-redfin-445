# Restore James-style detail sections in hybrid variant

**The problem**

In the hybrid variant, the detail sheet sits over a translucent thick-material background with the photo scroll showing through behind it. This causes the section cards, buttons, illustrations, and icons to look washed out, blended into the photos, and visually broken — instead of looking like the clean, opaque, white-card sections in the James variant.

**What I'll change**

- Switch the hybrid detail sheet background from translucent thick material to a solid app background, so the sections sit on a clean surface — exactly like the James detail page.
- Ensure section spacing, padding, and the price/address header match the James layout precisely (top padding above the price, consistent horizontal padding, container spacing).
- Keep all existing hybrid behavior intact: the sheet still slides up from collapsed peek to expanded, dragging still works, the photo scroll still lives behind the collapsed peek, and the floating Ask Redfin input still appears when enabled.
- Verify the rate summary card, "Request showing" button, property details grid, feature highlights, payment breakdown, "Take a tour" illustration, "Ask Redfin" panel, and Lifestyle grid all render with the same styling, icons, and buttons as the James variant.

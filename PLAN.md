# Remove duplicate Ask Redfin input + dynamic placeholder text

## Remove the duplicate

- On the hybrid detail page, remove the floating Ask Redfin bar that was recently re-added at the bottom of the screen.
- Keep only the original Ask Redfin input that lives inside the detail sheet content (the one that was there before).
- Result: a single Ask Redfin entry point on detail pages — the bottom tab bar accessory — plus the in-sheet Ask Redfin section.

## Dynamic placeholder text in the Ask Redfin accessory bar

The Ask Redfin accessory bar's placeholder ("Ask anything...") will adapt based on what the user is currently looking at, only when the accessory variant is active. Suggestions rotate every few seconds within a given context, then snap to the next set when context changes.

### Contexts and rotating suggestions

- **Default (home / browsing lists):**
  - "Ask anything..."
  - "What's a good neighborhood for families?"
  - "Help me compare two homes"

- **Map / neighborhood view:**
  - "What's it like living here?"
  - "How are the schools in this area?"
  - "Walkable to coffee shops?"

- **Detail page – top / hero:**
  - "Is this priced fairly?"
  - "How long has this been listed?"

- **Detail page – scrolled to price / payment section:**
  - "How does this price compare to nearby homes?"
  - "What would my monthly payment look like?"

- **Detail page – scrolled to property details / features:**
  - "What stands out about this home?"
  - "Any red flags in the details?"

- **Detail page – scrolled to schools / lifestyle:**
  - "How are the schools nearby?"
  - "What's the commute like?"

- **Photo focused (tapped into a photo):**
  - "What are these countertops made of?"
  - "What style is this kitchen?"
  - "Estimate the cost to redo this room"

### Behavior

- Suggestions cross-fade every ~3.5 seconds.
- When the user changes context (taps a photo, scrolls into a new section, opens the map), the placeholder smoothly transitions to that context's first suggestion.
- Tapping the accessory bar still opens the chat as it does today; the currently-shown placeholder is used as the initial chat prompt hint.
- Reduce Motion users see no cross-fade — placeholder swaps instantly.
- Only applies when the accessory variant is enabled; the app-nav variant FAB is unchanged.
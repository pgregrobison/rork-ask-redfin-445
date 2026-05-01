# Tighten Ask Redfin suggestions and add map card context

**Goal:** Trim every placeholder suggestion to 30 characters or fewer so they fit cleanly in the input, and introduce a new set of suggestions for when a map home card is selected.

**Suggestion updates (all ≤30 chars):**

- Default
  - "Ask anything..."
  - "Compare two homes"
  - "Best areas for families?"
- Map (browsing pins, no card selected)
  - "What's it like here?"
  - "Schools in this area?"
  - "Walkable to coffee?"
- Map card selected (NEW)
  - "Tell me about this home"
  - "Why this price?"
  - "What's the catch?"
  - "Compare to nearby homes"
- Detail – hero
  - "Is this priced fairly?"
  - "How long on market?"
- Detail – price
  - "Price vs. nearby homes?"
  - "Estimate my payment"
  - "Is this a good deal?"
- Detail – features
  - "What stands out here?"
  - "Any red flags?"
- Detail – lifestyle
  - "Schools nearby?"
  - "What's the commute?"
- Photo focus
  - "What are these counters?"
  - "What style is this?"
  - "Cost to redo this room?"

**Wiring:**

- Add a new "map card selected" state to the suggestion model.
- On the map screen, switch to that state whenever a home card is showing for a tapped pin, and revert to the regular map suggestions when the card is dismissed.
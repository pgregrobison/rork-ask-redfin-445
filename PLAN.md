# Chat-to-Find filter sync in Realistic Mode

When Realistic Mode is on, the chat will actually understand what you're asking for and apply real filters to the Find surface — beds, baths, price range, property type, and neighborhood — based on the two sync modes you defined.

**Bi-directional sync mode**
- After the 8-second "Searching homes" completes and results arrive in chat, the Find map and list automatically update to reflect those exact filters.
- Example: typing "3 bed in upper west side" in chat → after thinking completes, Find switches to show only 3+ bed homes, the map fits to the Upper West Side listings, and the filter chips above the map show "Upper West Side" and "3+ beds."
- If you're already on the map with chat overlaid (map focus mode), filters apply as the chat results settle — same timing as today.

**One-way sync mode**
- Nothing on Find changes automatically, no matter how much you chat.
- When you tap "Show on map" in a chat result, the chat's filters are merged on top of whatever filters you already had on Find (e.g. if Find had "max $2M" set and chat derived "3 bed, Upper West Side," the result is all three combined).
- The map fits to the merged results and filter chips update to show the full set.

**Natural language understanding**
The chat already extracts beds, price caps, property type, neighborhoods, and "hot homes" from messages. This same extraction now drives the Find filters — nothing new to learn on your end. Supported neighborhoods include Manhattan, Brooklyn, Queens, LIC, Astoria, Williamsburg, Upper West Side, Upper East Side, Tribeca, and SoHo.

**Visual feedback on Find**
- Active filter chips appear above the map the same way they do when you set filters manually — no special "from chat" label.
- The home count pill updates to reflect the filtered results.
- The map animates to fit the filtered listings.

**Out of scope**
- Non-realistic mode behavior is unchanged.
- Baths and sqft extraction from chat aren't part of today's chat parser; only filter types the chat already extracts will sync. (If you want baths/sqft understood from chat too, that's a follow-up.)

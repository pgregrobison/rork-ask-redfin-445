# Make chat filters actually filter results and sync with Find

## Problem

Right now when you say something like "3 bed in Upper West Side" in chat, the criteria is extracted but the home cards shown in chat don't reliably reflect it, and the Find page isn't updated to match either. Neighborhoods in particular don't work because listings only store a city ("New York"), not a neighborhood, so Upper West Side never matches.

## Behavior after this change

**In chat (home cards shown inside the thread):**
- Chat results always reflect the **combined** filter set: current Find filters + filters from the new message.
- Works identically in bi-directional and one-way sync — both modes preview the same combined result set inside chat.
- Filters are flexible: "3 beds" → 3+ bedrooms, "under $1M" → max $1M, "Upper West Side" → that neighborhood, etc.

**Conflict resolution when chat overlaps existing Find filters:**
- Beds, baths, property type, hot homes: chat **replaces** the existing value.
- Price range: chat replaces (3 beds under $2M replaces prior price ceiling).
- Neighborhoods: **replace by default**. If the message includes words like "add", "also", "include", or "plus" (e.g. "also show Tribeca"), the neighborhood(s) are **added** to the existing set instead.

**Applying to Find:**
- **Bi-directional sync:** As soon as chat results are ready, Find's filter chips and map/list update to match the combined set. The map camera recenters to the neighborhood bounds if one was mentioned.
- **One-way sync:** Find doesn't change until you tap "Show on map". When you do, the same combined filters and map recenter are applied.

**Map recenter:**
- When a neighborhood is mentioned (Upper West Side, Tribeca, Brooklyn, etc.), the map camera zooms to that neighborhood's approximate bounds.
- If multiple neighborhoods are mentioned, the map fits them all.
- If no neighborhood is mentioned, the camera fits the resulting listings as it does today.

## Under-the-hood fixes this requires

1. **Listings need a neighborhood concept.** Today listings only store a city, so "Upper West Side" never matches anything. I'll tag each mock listing with a neighborhood derived from its address/description (Upper West Side, Upper East Side, Tribeca, SoHo, Hudson Yards, West Village, Midtown, Williamsburg, Bushwick, LIC, Astoria, etc.). Both chat and Find will filter on this field.

2. **Chat search should respect current Find filters.** Chat's search will merge the message's filters into the current Find filter state using the conflict rules above, then return the listings matching the combined set. The "narrow to top city only" behavior in chat search will be removed — it currently drops valid matches.

3. **Neighborhood bounds table.** A small lookup mapping each known neighborhood name to an approximate lat/lon region, used to recenter the map.

4. **"Add vs replace" detection for neighborhoods.** Simple keyword check on the user's message ("also", "add", "include", "plus", "and show").

5. **One-way preview without mutating Find.** Chat will compute the preview set by running the merge on a temporary copy of the current filters, so Find state stays untouched until Show on map is tapped.

## What doesn't change

- Realistic Mode, its 8-second thinking time, and the bi-directional / one-way toggle stay exactly as they are.
- Tour and mortgage flows are untouched.
- Non-Realistic Mode behavior is unchanged (chat still returns standalone results with no Find syncing).

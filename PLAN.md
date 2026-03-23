# Unified Home Card Component

Create a single reusable home card component used everywhere a listing appears. Changes to core elements (photo, price, stats, address, tags, actions) will automatically ripple across all surfaces.

**Card Sizes / Variants**

The unified card supports different display modes depending on where it's used:

- **Large** — Full-width card used in the list view (Find tab, Saved tab). Tall photo (240pt), full price, stats, address, tags, heart + share actions.
- **Medium** — Horizontal scroll card used in Ask Redfin chat (300pt wide). Slightly smaller photo, full price, stats, address, tags, heart action only.
- **Compact** — Horizontal scroll card used in For You sections (280pt / 260pt wide). Smaller photo, headline price, stats, address, tags, heart action only.
- **Map Overlay** — The map selection card keeps its own photo carousel and dismiss button, but its info section (price, stats, address, actions) will now use the same shared component so formatting stays consistent.

**Consistent Formatting Across All Cards**

- Stats always show: `3 bd · 2 ba · 1,200 sq ft`
- Address always shows full: `123 Main St, NYC, NY 10001`
- Tags appear on all sizes, styled uniformly as small pills
- Heart (save) button on all cards; share button only on large cards and map overlay
- Badges (HOT HOME, LISTED BY REDFIN, days ago) rendered consistently via the shared component

**What Changes**

- A new shared `HomeCard` view is created with a `size` parameter
- `ListingListCard`, the inline cards in `ChatListingCards`, and the inline cards in `ForYouView` are all replaced by the new `HomeCard` with the appropriate size
- `ListingCardOverlay` (map overlay) replaces its info section with the shared card's info sub-view
- `SavedView`, `FindListView`, `ChatListingCards`, and `ForYouView` are updated to use `HomeCard` instead of their old custom card views

No changes to navigation, data models, or overall layout — just consolidating the card UI into one source of truth.
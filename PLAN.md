# Transparent chat header with scroll fade effect

**Changes**

- Remove the solid/opaque background from the Ask Redfin chat header so chat messages are visible all the way to the top edge of the sheet
- Make the header overlay the scroll content (floating on top) instead of sitting above it in a VStack
- Add a progressive gradient fade mask at the top of the chat so messages gracefully dissolve as they scroll under the header area
- Extend the scroll content to start beneath the header with appropriate top padding so nothing is hidden initially

**Design**

- The thread switcher pill and close button float transparently over the chat
- As messages scroll up behind the header, they progressively fade out via a linear gradient mask — creating a clean, native feel
- No abrupt cutoff — smooth opacity transition from fully visible to fully transparent over ~60pt
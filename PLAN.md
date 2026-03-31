# Let chat text scroll freely under the header with gradient fade

**What changes**
- The header moves from being stacked above the chat to being attached as a top safe-area inset of the ScrollView
- This means the chat content extends all the way up behind the header instead of getting clipped at the header's bottom edge
- The existing gradient background on the header will naturally fade the text as it scrolls beneath it — no hard clip
- A small top content margin is added so messages start below the header when at rest

**What stays the same**
- Header stays visually in the same position with the same gradient style
- All scroll behavior (restore position, scroll-to-top/bottom, thread switching) unchanged
- Input footer and voice mode unchanged
- All existing animations and interactions preserved
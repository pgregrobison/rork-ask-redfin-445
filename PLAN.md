# Fix chat auto-scroll: stop scroll-back on bot finish & fix iPhone positioning

**Problem 1: Chat scrolls back down when bot finishes responding**
- Currently, when the bot's response finishes streaming, the large spacer that holds the user's message at the top is animated away, which causes the entire chat to collapse downward
- **Fix:** Remove the automatic spacer collapse when the bot finishes. Instead, the spacer will only reset when the user sends a new message or switches threads (both already handled). This keeps the user's message pinned at the top even after the bot finishes.

**Problem 2: On iPhone, user message only scrolls halfway up**
- The spacer height is calculated using the visible area of the scroll view, but on a real device with the notch and home bar, the measured height may be smaller than expected
- **Fix:** Use a more generous spacer height calculation that accounts for safe area differences, ensuring the user message reliably reaches the top on all devices

**Changes summary:**
- Remove the code that collapses the spacer when the bot stops streaming
- Adjust the spacer height formula to be more robust on real devices
- Clean up the now-unused collapse function and streaming phase tracking
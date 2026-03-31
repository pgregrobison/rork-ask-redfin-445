# Persist horizontal home carousel scroll positions in Ask Redfin

**What changes**

- Each horizontal home carousel in the chat will remember which listing card you scrolled to
- When you close and reopen Ask Redfin, every carousel will be at the same position you left it — so you can pick up right where you left off and swipe to the next home
- Scroll positions are stored per message, so switching between chat threads also preserves each carousel's position

**How it works**

- The app tracks which listing card is currently visible in each carousel (keyed by the chat message it belongs to)
- When Ask Redfin is dismissed or a thread is switched, those positions are saved
- When Ask Redfin is reopened or a thread is restored, each carousel scrolls back to the saved listing

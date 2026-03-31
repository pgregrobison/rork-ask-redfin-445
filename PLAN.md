# Fix chat freeze caused by layout feedback loop

**Problem**
Tapping "Ask Redfin" freezes the app because the bottom padding of the chat dynamically recalculates based on the scroll area height, which itself changes when the padding changes — creating an infinite loop.

**Fix**

- Remove the dynamic bottom padding that depends on scroll measurements
- Instead, calculate the extra space needed **once** when the view appears (using a one-time geometry measurement of the sheet height), and keep it stable
- This breaks the feedback loop while preserving the scroll-to-top-of-viewport behavior for user messages
- All other scroll behaviors (auto-scroll on send, snap-back from empty space, keyboard dismiss, thread switching) stay exactly the same


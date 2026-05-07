# Fix crash when tapping the tour day notification from background

**What's happening**

When you tap the tour day notification from the lock screen or background, the app launches and tries to do too many things at once: open the Ask Redfin chat, create a brand new Tour Day thread, and start streaming messages — all in the same instant the screen is still being built. That race causes the crash.

**The fix**

- After tapping the notification, open Ask Redfin first, then start the Tour Day thread a moment later once the chat is fully on screen.
- Make sure that if the notification arrives during the cold launch (before the main screen is ready), it still gets picked up and triggers Tour Day correctly instead of being missed.
- Keep the existing behavior intact: a new Tour Day thread is created, the route map appears, and the scripted assistant messages stream in.

**Result**

Tapping the tour day notification — from the lock screen, from a banner, or while the app is already open — reliably opens Ask Redfin and kicks off the Tour Day flow without crashing.
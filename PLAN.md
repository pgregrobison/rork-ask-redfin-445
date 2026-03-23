# Replace AI Chat with Keyword-Based Demo Responses

## What's Changing

The chat currently tries to connect to a real AI service (which fails). We'll replace it with a simple keyword-matching system that responds to specific words/phrases with pre-written replies — no internet connection needed.

---

**Features**

- Type anything containing **"home"**, **"house"**, **"apartment"**, **"condo"**, **"listing"**, or **"find"** → the bot responds with a brief message and shows property listing cards from the mock data
- Type anything containing **"tour"**, **"schedule"**, or **"visit"** → the bot suggests scheduling a tour with a helpful message
- Any other message → the bot replies with a friendly nudge like *"I can help you find homes or schedule tours. Try asking me about homes in NYC!"*
- Responses appear with a **simulated typing animation** (characters stream in with a short delay) so it feels realistic
- The "thinking" indicator still shows briefly before the response starts streaming
- Everything works **fully offline** — no network calls, no API keys needed

**What stays the same**

- All existing chat UI (bubbles, listing cards, thread management, feedback buttons)
- The search/filter logic that picks which listings to show
- Thread history and persistence

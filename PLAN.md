# Rebuild Ask Redfin Chat — Fresh Service, Models & ViewModel


## What's changing

Scrapping all chat backend logic (models, service, viewmodel) and rebuilding from scratch with the correct API format. The UI views (AskRedfinView, ChatMessageBubble, ChatListingCards, etc.) stay untouched.

---

### **Step 1 — Rewrite ChatModels**
- Simplify the data models to only what's needed right now
- Keep: `ChatMessage`, `ChatThread`, `ChatRole`, `MessageFeedback`, `SearchFilters`
- Remove for now: `TourRequest`, `MortgageRequest`, `ToolCall` complex types (will add back later)
- Add a simple `ToolInvocation` type for search results
- Clear saved chat threads on first launch so old incompatible data doesn't cause issues

### **Step 2 — Rewrite ChatService from scratch**
- Build a clean, minimal networking layer targeting the Rork toolkit `/agent/chat` endpoint
- Correctly format the request body to match the Vercel AI SDK format the server expects
- Only define the `searchListings` tool (search for homes by filters)
- Parse the Server-Sent Events (SSE) stream response — handle text deltas, tool calls, and finish events
- Use proper auth headers (`x-project-id`, `x-team-id`, `x-app-key`) from environment variables
- Add detailed error logging so if something goes wrong, we can see exactly what the server returned

### **Step 3 — Rewrite ChatViewModel**
- Clean message flow: user sends → stream AI response → handle tool calls → show results
- When the AI calls `searchListings`, execute locally against mock data and feed the result back to continue the conversation
- Simple thread management (create, switch, delete)
- Proper streaming state (thinking indicator while waiting)

### **Step 4 — Reconnect to existing UI**
- Ensure the rebuilt models/viewmodel match what AskRedfinView, ChatMessageBubble, and ChatListingCards expect
- Keep the same property names where possible so the UI views compile without changes
- If any small UI file tweaks are needed for compatibility, make minimal edits

### **What stays the same**
- All UI views (AskRedfinView, ChatMessageBubble, ChatListingCards, ThinkingIndicator, etc.)
- The floating Ask Redfin button and sheet presentation
- The suggestion chips in the empty state
- Feedback (thumbs up/down) on messages
- Listing cards appearing inline in chat results
- Tour scheduler and mortgage widgets remain in the UI but won't be triggered until those tools are added back later

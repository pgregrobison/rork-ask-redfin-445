# Integrate real AI into the chat (Claude Sonnet 4.6, streaming, tool calls)

Replace the canned `ChatService.matchResponse` flow with a true LLM-driven loop while preserving the existing UI states (`.thinking` / `.searching`), Realistic Mode delays, and listing-card / tour / mortgage rendering.

## Model
- `anthropic/claude-sonnet-4.6` via Rork proxy `/v2/vercel/v1/chat/completions`

## Implementation
- [x] Confirm model endpoint via `getModelUsage` and provision toolkit secret
- [x] Create `Services/AIService.swift` — SSE streaming client emitting `AIEvent` (textDelta, toolCallStart, toolCallArgsDelta, finish, error)
- [x] Create `Services/ToolExecutor.swift` — runs `search_homes`, `schedule_tour`, `prequalify` tool calls, reusing `ChatService.mergeFilters` + `searchListings`
- [x] Create `Services/ChatPromptBuilder.swift` — system prompt + history mapping with current Find filters context
- [x] Rewrite `ChatViewModel.generateResponse` to drive the SSE loop, write text deltas live to the streaming bubble, and stamp `searchResults`/`tourRequest`/`mortgageRequest` onto the final message so existing map sync keeps working
- [x] Honor Realistic Mode 8s minimum on `search_homes` and 2s minimum on `.thinking` for non-search replies
- [x] Build until green

## Tool schemas
1. `search_homes` — `min_beds`, `min_baths`, `max_price`, `property_type`, `neighborhoods[]`, `is_hot_home`, `add_neighborhoods`
2. `schedule_tour` — `address?`, `listing_id?`
3. `prequalify` — `listing_id?`

## Unchanged
- `ChatService.searchListings` + `mergeFilters` (reused by `ToolExecutor`)
- `ContentView` map-sync, Realistic Mode bidirectional vs. one-way, sheet detents, map shimmer
- Voice mode, tour-day thread, listing cards, feedback, thread switcher

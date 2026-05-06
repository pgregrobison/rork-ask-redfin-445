# Tour Day — guided multi-stop tour experience in Ask Redfin

## What gets built

A scripted, on-rails Tour Day flow that triggers when you type "tour day" into Ask Redfin. It creates a dedicated thread, walks through 4 demo home tours with a route map, lets you open directions in Apple or Google Maps, and uses the existing voice mode for between-stop check-ins.

## Trigger
- Typing a message containing "tour day" in any Ask Redfin thread spins up a brand-new Tour Day thread, switches to it, and posts a welcome message: "Welcome to tour day! I've created a new thread for all things tours."
- A subtle haptic + a simulated push-style banner slides down from the top to reinforce the moment.

## The Tour Day thread
- Marked with a small calendar/route icon in the thread switcher dropdown so it stands out from regular chats.
- Title: "Tour Day · [today's date]".

## Route map message
- A rich chat bubble featuring:
  - A MapKit snapshot at the top with numbered pins (1–4) and a drawn polyline connecting them in optimized order.
  - A numbered stop list below: address, neighborhood, and tour time for each home.
  - A single primary CTA: "Open directions".
- Tapping the CTA opens an action sheet with two choices: **Apple Maps** and **Google Maps**. Selecting either launches that app with the multi-stop route.
- Tapping the map itself expands it full-screen for closer inspection.

## Auto-advancing tour flow
- After the route message, a short timer (a few seconds, demo pacing) advances to the next stop automatically.
- Between stops, the assistant proactively says things like: *"On your way to the 2nd tour — let me know what you thought of the first home."*
- Each stop shows a compact card naming the current home (address + thumbnail) so you always know where you are in the day.

## Voice check-ins
- Uses the existing waveform/voice button already in the Ask Redfin input field — no new entrypoint.
- When the assistant prompts for thoughts, the input subtly hints "Tap the waveform to reply by voice."
- In voice mode, the existing pulsating orb animates as if the AI is speaking back; the orb's pulse intensity is driven by a scripted volume curve so it feels alive.
- A scripted user reply ("I loved the kitchen but the backyard was small") appears as if transcribed, the assistant verbally acknowledges, then voice mode auto-closes and the next stop kicks off.

## Wrap-up
- After the 4th stop, the assistant posts a final summary message: *"Here's a recap of what you loved and didn't — I've passed this along to your agent."* with a short bulleted summary of the (scripted) feedback. No agent integration needed.

## Design
- Tour Day messages follow the existing Ask Redfin bubble style — no new visual language, just a calendar/route accent icon on the route message and stop cards.
- Map snapshot uses Redfin red for the route polyline and pin numbers to tie it to the brand without leaking red elsewhere.
- Smooth spring animations as new stops appear; gentle haptic on each stop transition.
- Works in both light and dark mode; respects existing Theme tokens.

## What is NOT in scope
- No real backend, no real push notifications, no real AI/voice — fully simulated for the demo.
- No changes to non-Tour-Day chat behavior.
- No agent messaging integration.
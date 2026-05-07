# Polish Tour Day banner + pacing + voice prompt message

**Banner appears above the chat**
- The tour day notification will float above everything, including the Ask Redfin chat window, using a dedicated top-level window layer so it never slides in behind the chat.
- Visual styling matches the original iOS-style notification (logo, "ASK REDFIN", "now", title + subtitle, soft blurred background, subtle shadow, swipe-up to dismiss, tap to open the new tour thread).

**Slower, more realistic pacing**
- Add a ~8 second buffer between each tour stop so the script feels like you're actually driving between homes.
- Initial route reveal and summary message keep their current pacing.

**Voice prompt becomes a chat message**
- Remove the floating pill hint at the bottom of the chat.
- After the first stop card, the assistant sends a normal chat bubble that reads: "Tap the 〈waveform〉 and let me know what you thought of this home!" with the waveform shown inline as an SF Symbol next to the word.
- The mic/waveform button in the chat input keeps its existing behavior for triggering voice mode.

**Out of scope**
- No changes to the route map widget, stop cards, voice mode UI, or summary message.
# Redesign Voice Mode as Inline Experience

## What's Changing

Replace the full-screen voice mode overlay with a compact, inline voice experience that lives just above the chat input.

### **Features**
- Tapping the voice icon (when no text is typed) activates voice mode inline — no full-screen takeover
- The keyboard dismisses automatically when voice mode activates
- A medium-sized (~100pt) pulsating orb with a subtle accent color appears just above the input bar, animated smoothly in
- The voice icon seamlessly transforms into an **X** (close) button in-place, using identical styling to the send button (solid circle, primary color)
- A **mute toggle** button appears to the left of the X, with secondary styling (lighter background)
- Muting toggles the mic icon (filled ↔ slashed) without affecting the orb animation
- Tapping X exits voice mode, smoothly animating the orb away and restoring the voice icon
- Simulated live transcription: words appear one-by-one as a user message bubble (anchored to top of viewport, like a normal sent message)
- After the "user stops speaking," a bot response streams in below the transcript — same as regular chat

### **Design**
- The orb uses a subtle accent-colored radial gradient (Redfin green tones) with soft glow rings
- Orb pulsates with the same breathing animation style as before, but smaller and inline
- The X button matches the send button exactly: solid primary-colored circle with contrasting icon
- The mute button uses a secondary style: lighter fill, matching circle size
- Smooth spring animations for orb appearing/disappearing and button swaps
- "Listening…" label sits just below the orb, subtle and secondary-styled
- The input field remains visible but disabled/dimmed during voice mode

### **Screens**
- **Ask Redfin chat (voice mode off):** Same as today — voice icon shows when input is empty
- **Ask Redfin chat (voice mode on):** Orb floats above the input bar; X and mute buttons replace voice/send in the input bar; live transcription appears as user message bubbles in the chat scroll; bot response streams after
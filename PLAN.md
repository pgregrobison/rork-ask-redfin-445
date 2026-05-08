# Add photo step to tour day stop 1 flow

## Changes to tour day flow

**Stop 1 — new photo step:**

1. Waveform prompt appears as today ("Tap the waveform and let me know what you think of this home!")
2. User taps the voice button → fake voice response streams in (kept as-is)
3. After a short delay, the bot adds a new short prompt: **"Snap a photo of something that stood out — good or bad."**
4. Auto-progression pauses here until the user sends a photo via the + menu (camera or library).
5. Once the photo message is sent, the bot replies: **"Wow! There are a lot of smart people in this home!"**
6. After ~4 seconds, tour day auto-progresses to stop 2 as normal.

**Stop 2 transition message:**

- Remove the trailing "— let me know what you thought of the first home." 
- New text: **"On your way to the 2nd tour."**

**Scope:**

- Photo step only happens for stop 1. Stops 2–4 behave as they do today.
- No changes to the post-tour summary, map widget, or voice flow for other stops.


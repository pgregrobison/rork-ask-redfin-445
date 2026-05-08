# Polish tour day flow for live demo

**Tour map widget**
- Change the small numbered "#" circles in the stop list to use Redfin brand red (matches the pins on the map above).
- Smoothly fade the entire tour map widget in (~0.5s ease-in-out) when it appears in chat, instead of popping in instantly.

**Stop 1 voice prompt**
- Keep the bot's immediate "First stop coming up… Heading to the Tribeca home now." response right after arrival.
- Remove the immediate follow-up message asking what the user thought.
- Instead, after a longer pause (long enough to feel like the user has actually walked through the home), show a new bot message: "Tap the [waveform] and let me know what you **think** of this home!" ("thought" → "think").

**Faked voice response**
- When the user taps the waveform during tour day, the simulated transcription becomes present tense: "I really like all the natural light and vaulted ceilings, but the kitchen is way too small."
- Update the post-tour summary handoff text to match this new present-tense phrasing.

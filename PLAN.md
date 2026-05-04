# Skip slide-up when switching between pins

**Behavior change**

- When a home card is already showing and you tap a different pin, the card stays in place and just swaps to the new home (no slide-down/slide-up).
- Tapping a pin from an empty map (no card visible) still slides up like before.
- Tapping the same pin again still dismisses the card with the slide-down animation.

**How it will feel**

- Quicker, less janky pin-to-pin browsing — the card simply updates its content while staying onscreen, with a subtle crossfade so the change is still noticeable.
- The map still pans to center the newly selected pin.
# Fix headers sliding in across all tabs

**The real issue**

Each tab's screen (For You, Saved, My Home, My Redfin, and Find) currently hides its own title until that tab becomes "active," then sets it back to the real title. Because each tab now has its own navigation stack, that toggle plays the standard large-title slide-down animation every time you switch tabs — which is what looks janky.

**Plan**

- Undo the previous Find-specific tweak so we're back to the original behavior there.
- Stop toggling the title and large/inline mode based on whether the tab is active. Each tab will simply declare its title once, so switching tabs no longer animates the header in from the top.
- Keep the toolbar buttons (profile, list/map toggle, sort) gated on active state where needed so they don't double up — only the title text/mode change is what was causing the slide.
- Result: tapping between For You, Saved, My Home, My Redfin, and Find will feel instant, with no header animation on switch.
# Fix Ask Redfin close button styling and sparkle button sizing

**Two fixes:**

### 1. Ask Redfin sheet close button
- Replace the custom glass-styled close button in the Ask Redfin sheet toolbar with a plain icon button (just the "xmark" image), matching how the detail page and map page toolbars work
- The native system toolbar already provides the circular glass appearance — layering a custom glass button on top creates a misshapen double-effect

### 2. Ask Redfin sparkle button on detail page
- Increase the sparkle button size from 44×44 to 52×52 so its height matches the "Request showing" button next to it
- This requires a size parameter on the glass button component, since the default 44×44 is correct everywhere else
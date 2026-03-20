# Fix property card action button positioning

**Problem**
- The share and heart buttons have 44×44pt tap targets, which when placed inline next to the price, force the entire row to be 44pt tall — creating a large gap beneath the price text.

**Fix**
- On the **list card** and **map overlay card**, move the share/heart actions out of the price row and overlay them on the card itself, positioned 4pt from the top edge and 4pt from the right edge of the card's info section.
- The price text will sit naturally without extra vertical space.
- The **chat listing card** heart icon will also be repositioned the same way for consistency.
- All action tap targets remain 44×44pt — only their position changes.
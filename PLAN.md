# Detail Page UI Cleanup — Containers, Icon+Tag Grid, & Section Restyling


## Summary
A comprehensive cleanup of the detail page to match the Redfin-inspired screenshot. Replaces divider lines with bordered containers, introduces an icon+tag grid pattern for Property Details and Lifestyle, and cleans up several sections.

---

### **Photo Area**
- Extend photo carousel to **50% of screen height** (currently 40%)
- **Remove** the badge overlay (top-left) and photo counter overlay (top-right) — they sit behind the toolbar and are redundant
- Keep carousel dots and segmented control overlaid at bottom
- **Remove extra background** from segmented control — let the native `Picker(.segmented)` handle its own styling

---

### **Remove Circular Action Buttons**
- Delete the Share / Heart / Ellipsis circle buttons row entirely — these are already in the native toolbar

---

### **Section Containers (replacing divider lines)**
- Every section becomes a **bordered container**: clear background, subtle border stroke, 20pt corner radius, 24pt internal padding
- 16pt vertical spacing between containers
- Sections wrapped in containers: Property Details, Rate/Payment, Take a Tour, Ask Redfin, Lifestyle
- Description stays outside containers (flows naturally after highlights)

---

### **Property Details Section — Icon + Tag Grid**
- Change from current horizontal icon+text rows to a **2×3 grid of icon+tag cells**
- Each cell: **32pt icon** centered above, with a **tag component** below as the label
- The highlights/features (Modern fixtures, Stunning island, etc.) will be **integrated into this same grid** rather than repeated separately — each feature gets a large icon above its tag
- Below the grid: the property description text and "Full property details" button

---

### **Rate Section — Full-Width Container**
- Expand into a **full-width bordered container** with a very subtle accent highlight (e.g. faint tinted border or background wash)
- Contains: monthly payment amount, breakdown list, payment bar, home price / down payment / loan details inputs
- **"Estimate my payment & rate" button** moves inside this container at the bottom
- The "Takes about 3 minutes" / "Won't affect your credit score" reassurance text stays below the button

---

### **Lifestyle Section — Icon + Tag Grid**
- Replace the current pill-style labels with the **same icon+tag grid pattern** used in Property Details
- 32pt icons (walk, bicycle, moon, leaf) centered above tag labels ("Walker's paradise", "Some bike-ability", etc.)
- "How is this calculated?" and attribution text remain below the grid

---

### **Take a Tour & Ask Redfin Sections**
- Wrapped in bordered containers with 20pt radius, 24pt padding
- No layout changes beyond the container treatment

---

### **Theme Tokens**
- Add a new `Theme.Container` namespace with: `radius: 20`, `padding: 24`, `spacing: 16`, `borderColor`, `borderWidth`
- Add `Theme.IconTag` namespace for the icon+tag grid pattern: `iconSize: 32`, `gridSpacing`

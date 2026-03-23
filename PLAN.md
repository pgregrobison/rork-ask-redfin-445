# Pin Selection Behavior — Full Spec Implementation

## What's Changing

Updating the map pins and their selection behavior to match the detailed spec you provided.

### **Pin Visual Style**
- **3 states**: Default (white/black), Seen (gray), Selected (red) — with proper light/dark mode colors
- **Shape**: Pill/capsule with 10pt horizontal and 6pt vertical padding
- **Font**: System bold, 13pt, tight letter spacing (-0.3)
- **Shadow**: Subtle drop shadow on all pins
- **No scale effect** — color change only when selected

### **Selection Behavior**
- Tapping an unselected pin selects it, marks it "seen", centers the map camera, shows the preview card, and hides the tab bar
- Tapping the already-selected pin deselects it, dismisses the card, and brings back the tab bar
- Tapping the map background dismisses the selection (same as tapping the selected pin)
- Switching between pins instantly updates the card and camera — old pin becomes gray "seen"

### **Animation Timing**
- Card appears with a spring animation (response 0.4, damping 0.75)
- Card dismisses with a quick ease-out (0.2s)
- Camera centers on selected pin over ~400ms
- Tab bar hides/shows with a 250ms slide

### **"Seen" State**
- Session only — resets when the app relaunches
- Seen pins stay gray even after deselection

### **Price Formatting** (already implemented, no change needed)
- ≥1M → "$1.95M" (trailing zeros stripped)
- ≥1K → "$640K"

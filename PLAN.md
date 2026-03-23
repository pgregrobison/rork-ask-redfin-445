# Redesign Listing Detail Page with Photo Scroll + Detail Sheet

## Overview
Completely rebuild the listing detail page to match the Redfin-style design with a full-screen photo scroller behind a draggable detail sheet, plus a focused photo viewer.

---

### **Features**

- **Vertically scrolling photo gallery** fills the full screen behind the detail sheet
- **Draggable detail sheet** overlays the photos with two stops: collapsed (showing price, stats, address, map thumbnail) and full height (all details)
- **Photos scroll independently** from the detail sheet — you can browse photos while the sheet stays in place
- **Tapping a photo** opens a focused photo viewer with the photo centered on a black background
- **Swipe left/right** in the focused view to browse all photos
- **Swipe down or tap back** to dismiss the focused photo viewer
- **Sticky footer** with "Request showing" button and sparkle button always visible at the bottom
- **Glass-style navigation buttons** (close, heart, share) float over the photos
- **Mini map thumbnail** next to the price showing the property's actual location via MapKit

---

### **Design**

- **Photo gallery**: Full-bleed photos stacked vertically with 2pt spacing, scrollable behind the sheet
- **Navigation header**: Glass-effect circular buttons — close (X) on the left, heart + share grouped on the right — floating over the photos with safe area padding
- **Detail sheet**: White card with rounded top corners, system drag indicator, snaps between a peek height (price + stats + address + map thumbnail) and full screen
- **Collapsed sheet** shows: bold price, bed/bath/sqft stats, full address, and a small rounded MapKit snapshot on the right
- **Expanded sheet** reveals: About this home (with "Continue reading"), days/views/favorites stats, Key Facts grid, Hot Home badge, Highlights tags, and more sections
- **Map thumbnail**: Small rounded rectangle showing a real MapKit snapshot with a green pin at the property location
- **Footer**: Red "Request showing" button + glass sparkle button, always pinned to the bottom edge above the safe area
- **Focused photo view**: Black background, photo centered and fitted, same glass nav header (back arrow replaces X), same sticky footer, swipeable between photos

---

### **Screens**

1. **Listing Detail (base)** — Full-screen photo scroll with overlaid glass nav buttons, draggable detail sheet at bottom, sticky footer
2. **Focused Photo Viewer** — Black background, centered photo, back button in nav header, swipe between photos, same sticky footer persists

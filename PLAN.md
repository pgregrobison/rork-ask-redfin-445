# Detail Page Styling Updates — Segmented Control, Rate Banner, Inputs, and More

## Changes

### 1. Segmented Control Glass Fix
- Match the liquid glass overlay height and corner radius exactly to the native segmented control so it doesn't bleed beyond the edges

### 2. Price/Address Spacing
- Slightly increase the vertical gap between the price, beds/baths/sq ft line, and address line for better breathing room

### 3. Rate Summary Mini Banner
- Redesign the rate section to match the screenshot: a full-width container with a light green tint background
- Left side: monthly rate in bold green text + "Rates dropped" subtitle with an info icon, all in brand green
- Right side: a dark green filled pill button saying "Estimate my rate"

### 4. Remove "Feature Highlights" Header
- Remove the "Feature highlights" container title text — keep only the icon/tag grid and description below it

### 5. New Input Component
- Create a reusable filled input component: 68pt tall, subtle inset background, rounded corners
- Label inside (smaller text, top-left), value below label (larger text), optional right-justified icon
- Replace the "Home price" and "Down payment" inputs with this new component
- Replace the "Loan details" section with this component as well

### 6. Checkmark Items in Own Container
- Move the two checkmark items ("Takes about 3 minutes", "Won't affect your credit score") into their own bordered container matching the section style
- Left-align the checkmark items, filling the container width

### 7. Home Illustration for "Take a Tour"
- Generate an isometric 3D-style house illustration
- Replace the current SF Symbol house icon in the "Take a Tour" section with the generated illustration

### 8. Ask Redfin Section Updates
- Replace the chat bubble icon with the sparkle icon (matching the Ask Redfin FAB)
- Update the button to secondary outlined style with a sparkle icon and text "Ask me about [street address]" using the listing's street address

### Design Notes
- All containers use our 20pt theme radius, 24pt internal padding
- Brand green color token used for the rate banner styling
- Input component uses the inset color token for its filled background

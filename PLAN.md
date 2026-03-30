# Compass Coming Soon Listings + Live Location + Push Notification

## Features

- **Compass Coming Soon badge** — A new black "COMPASS COMING SOON" tag appears on listing cards and map overlays, matching the existing badge style (like "14d ago" or "Listed by Redfin")
- **3 Compass Coming Soon mock listings** — New exclusive listings added to the NYC map that are flagged as Compass Coming Soon
- **Live user location dot** — Your current location appears on the map as a pulsing blue dot, just like Apple Maps
- **Push notification on locate** — When you tap the locate button and grant location permission, a native iOS push notification fires saying there's a Compass Coming Soon listing nearby with an exclusive preview
- **Notification deep link** — Tapping the notification takes you to the map tab and auto-selects the nearest Compass Coming Soon listing, panning the map to highlight it

## Design

- The "COMPASS COMING SOON" badge uses a solid black background with white bold text, consistent with other listing badges
- Map pins for Compass listings use the same price capsule style as all other listings — no visual distinction on the pin itself
- The user location dot is a vibrant blue circle with a subtle pulsing ring animation radiating outward, mimicking the native Apple Maps feel
- The push notification uses the standard iOS notification banner with the app icon, a title like "Exclusive Preview Nearby", and body text mentioning the address

## How It Works

1. **Badges**: Compass Coming Soon listings show the black badge on home cards, map overlay cards, and detail views — just like existing badges
2. **Map dot**: Once location permission is granted, a pulsing blue dot appears at your position on the map
3. **Notification trigger**: The first time you tap the locate button and permission is granted, a local push notification is scheduled after a short delay (simulating a real push). This only fires once per session to avoid spam
4. **Tapping the notification**: The app navigates to the Find/Map tab, dismisses any open sheets, and selects the nearest Compass Coming Soon listing to your location — smoothly panning the map to it

# Fix sluggish pin selection and map action icon glitching

**Problem**

- Pin selection pans the map too slowly (0.4s ease-in-out)
- The broad animation scope causes the map action buttons (layers, draw, location) to blur and re-grow when a pin is selected

**Fixes**

1. **Faster map pan**: Replace the slow 0.4s ease-in-out with a snappy 0.25s ease-out animation for the map camera movement
2. **Isolate card animation from map actions**: Scope the spring animation so it only affects the listing card appearance — not the entire view tree. This prevents the glass action buttons from being caught in the animation
3. **Prevent action button re-renders**: Wrap the map action button overlay in a container that isn't affected by selection state changes, so they remain completely stable during pin selection


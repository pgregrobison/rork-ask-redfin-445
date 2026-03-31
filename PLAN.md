# Move chat header back into VStack with gradient background

**What changes:**

- Move the header out of the overlay `ZStack` and back into the normal vertical layout (above the message list)
- Give the header a gradient background that fades from solid to transparent at the bottom, so chat text is subtly visible as it scrolls beneath
- Remove the extra top padding on the message list that was compensating for the overlay header
- All existing functionality (thread switcher, dismiss button, glass effects) stays the same

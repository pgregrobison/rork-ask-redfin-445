# Fix Ask Redfin and close buttons to be perfect circles

**What's wrong:**

- The Ask Redfin sparkle button on the detail page footer is an oval, not a circle — it uses uneven padding instead of a fixed square size
- The close button inside the Ask Redfin chat sheet isn't a perfect circle because the system toolbar overrides its sizing

**What will change:**

- **Detail page sparkle button**: Switch from asymmetric padding to a fixed square frame (matching the 44×44 size used by all other circular glass buttons), with a `.circle` glass shape instead of `.capsule`
- **Ask Redfin close button**: Use a plain close button view in the toolbar that resists the toolbar's sizing interference, ensuring a perfect circle just like the close buttons elsewhere in the app
- Both buttons will use the exact same `GlassActionButton` component and sizing as every other circular glass button in the app


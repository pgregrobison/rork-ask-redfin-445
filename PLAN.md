# Native tab bar — default fills + brand tint

Reverted the accessory native tab bar to system defaults (icons always render as filled variants — iOS handles this automatically).

Applied `.tint(Theme.Colors.brandRed)` on the accessory `TabView` so selected icon and label use the Redfin brand red.

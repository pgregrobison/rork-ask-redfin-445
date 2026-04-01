# Move action buttons to native toolbar, pill as principal item

**What changes**

- **Native toolbar restored**: The list/map toggle, sort (list view only), and profile buttons move back into the native `.toolbar` as `ToolbarItem` placements (leading/trailing)
- **Pill as principal**: The location pill (with its morphing menu behavior) gets injected as `.principal` in the native toolbar — it sits centered between the leading/trailing actions, exactly where the native title would be
- **Menu as overlay**: When tapped, the pill menu expands as a floating overlay on top of everything (same morphing animation as today), positioned to align with the pill's location in the toolbar
- **Native transitions restored**: Because the navigation bar is no longer hidden, pushing to the detail page will have the smooth native sliding toolbar animation again
- **Custom ZStack toolbar removed**: The manually-positioned `toolbarActions` HStack in the ZStack gets removed entirely — all those buttons live in the native toolbar now
- **Everything else stays the same**: The morphing pill animation, location search, filter access, map action buttons (layers/draw/locate), and all other behavior remain unchanged
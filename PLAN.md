# Global persistent FAB + fix photo zoom transition

**Goals**

- Ask Redfin FAB stays anchored in the lower-right corner across every surface (Find, detail page, photo viewer) and stays visible even when the Hybrid detail sheet is pulled to .large.
- Tapping a photo on Hybrid detail opens the photo viewer with a proper zoom transition matching the card→detail zoom feel.
- FAB opens chat from anywhere via existing `viewModel.showChat = true`.

**Approach**

- Move the Hybrid detail FAB OUT of the parent overlay (which sits behind the sheet) and INTO an overlay on the sheet content itself. Because the sheet always extends to the screen bottom, a `.overlay(alignment: .bottomTrailing)` on the sheet content places the FAB at the screen's bottom-right at every detent, on top of the sheet.
- Keep the tab-bar FAB as is for Find/other tabs. They share the same position so the FAB feels persistent.
- Fix the photo button: add `.contentShape(.rect)` for reliable hit-testing and move `.matchedTransitionSource` to the Button itself.
- Keep `.fullScreenCover(item:)` + `.navigationTransition(.zoom(sourceID:in:))` — this is the supported iOS 18 zoom path.

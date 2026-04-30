# Add "Global entrypoint" debug toggle (App nav / Accessory)

**Goals**

- Add a debug menu option "Global entrypoint" with two values:
  - **App nav** — current behavior (custom 4-tab bar with Ask Redfin FAB).
  - **Accessory** — iOS 26 native `TabView` with 5 tabs (Find / For You / Saved / My Home / My Redfin) and `.tabViewBottomAccessory` hosting an Ask Redfin input bar styled identically to the chat sheet's input bar. Tab bar uses `.tabBarMinimizeBehavior(.onScrollDown)` so the bar collapses on scroll and the accessory moves inline next to the minimized tab.

**Approach**

- [x] Add `GlobalEntrypoint` enum + persisted property to `DebugSettings`.
- [x] Add `.myRedfin` case to `AppTab` (icon `person.crop.circle`).
- [x] Add Global entrypoint section to `DebugPanelView`.
- [x] Create `MyRedfinView.swift` — simple profile-style stub with debug entry point.
- [x] Create `AskRedfinAccessoryBar.swift` — input bar matching the chat sheet style; tap routes to `viewModel.showChat = true`.
- [x] In `ContentView`, branch on `globalEntrypoint`:
  - `.appNav` → existing layout.
  - `.accessory` (iOS 26 only) → native `TabView` with 5 `Tab`s, `.tabBarMinimizeBehavior(.onScrollDown)`, `.tabViewBottomAccessory { AskRedfinAccessoryBar(...) }`. No floating FAB.
- [x] Build succeeds.

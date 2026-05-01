import SwiftUI

/// Invisible, touch-passthrough scroll view used to drive the system
/// `.tabBarMinimizeBehavior(.onScrollDown)` animation on the map screen,
/// where there's no real list to scroll.
///
/// The system requires a real, hierarchy-recognized ScrollView to react to,
/// so this view must NOT use `.scrollDisabled(true)` (that prevents the
/// minimize behavior from picking it up). Touch passthrough is achieved
/// with `.allowsHitTesting(false)` only.
@available(iOS 26.0, *)
struct AccessoryScrollDriver: View {
    let minimized: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 1).id("top")
                    Color.clear.frame(height: 2000).id("bottom")
                }
            }
            .allowsHitTesting(false)
            .onChange(of: minimized) { _, val in
                proxy.scrollTo(val ? "bottom" : "top", anchor: .top)
            }
        }
    }
}

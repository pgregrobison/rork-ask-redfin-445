import SwiftUI

@available(iOS 26.0, *)
struct AccessoryScrollDriver: View {
    let minimized: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 1).id("top")
                    Color.clear.frame(height: 400).id("bottom")
                }
            }
            .scrollDisabled(true)
            .allowsHitTesting(false)
            .onChange(of: minimized) { _, val in
                withAnimation(.easeInOut(duration: 0.28)) {
                    proxy.scrollTo(val ? "bottom" : "top", anchor: .top)
                }
            }
        }
    }
}

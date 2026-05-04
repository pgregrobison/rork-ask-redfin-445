import SwiftUI
import UIKit

@main
struct RedfinCloneApp: App {
    @State private var showSplash: Bool = true

    // Matches the app icon background fill (display-p3 0.87059, 0.20000, 0.25490)
    private static let iconRedUI: UIColor = UIColor(displayP3Red: 0.87059, green: 0.20000, blue: 0.25490, alpha: 1)
    private let iconRed: Color = Color(.displayP3, red: 0.87059, green: 0.20000, blue: 0.25490, opacity: 1)

    init() {
        // Tint every UIWindow red so the very first pre-render frame
        // (during the icon-zoom transition) is Redfin red instead of
        // the system background, in both light and dark mode.
        UIWindow.appearance().backgroundColor = Self.iconRedUI
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                iconRed
                    .ignoresSafeArea()

                ContentView()

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(1000))
                withAnimation(.easeOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}

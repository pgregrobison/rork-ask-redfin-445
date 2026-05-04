import SwiftUI

@main
struct RedfinCloneApp: App {
    @State private var showSplash: Bool = true

    var body: some Scene {
        WindowGroup {
            ZStack {
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

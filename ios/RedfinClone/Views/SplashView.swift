import SwiftUI

struct SplashView: View {
    // Matches the app icon background fill (display-p3 0.87059, 0.20000, 0.25490)
    private let iconRed = Color(.displayP3, red: 0.87059, green: 0.20000, blue: 0.25490, opacity: 1)

    var body: some View {
        ZStack {
            iconRed
                .ignoresSafeArea()

            // Use the same asset and size as the native launch screen (Info.plist
            // UILaunchScreen.UIImageName = "LaunchLogo", which iOS centers at its
            // natural 200pt width). No entrance animation — the logo must appear
            // pixel-identical to where the system left it, so the handoff is invisible.
            Image("LaunchLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SplashView()
}

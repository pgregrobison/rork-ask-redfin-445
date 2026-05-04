import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.85
    @State private var logoOpacity: Double = 0

    // Matches the app icon background fill (display-p3 0.87059, 0.20000, 0.25490)
    private let iconRed = Color(.displayP3, red: 0.87059, green: 0.20000, blue: 0.25490, opacity: 1)

    var body: some View {
        ZStack {
            iconRed
                .ignoresSafeArea()

            Image("RedfinLogo")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: 200)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}

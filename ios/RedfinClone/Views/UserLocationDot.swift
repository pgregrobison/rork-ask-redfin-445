import SwiftUI

struct UserLocationDot: View {
    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 44, height: 44)
                .scaleEffect(isPulsing ? 1.0 : 0.5)
                .opacity(isPulsing ? 0.0 : 0.6)

            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 44, height: 44)
                .scaleEffect(isPulsing ? 0.7 : 0.3)
                .opacity(isPulsing ? 0.3 : 0.6)

            Circle()
                .fill(.white)
                .frame(width: 16, height: 16)

            Circle()
                .fill(Color.blue)
                .frame(width: 12, height: 12)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
        .allowsHitTesting(false)
    }
}

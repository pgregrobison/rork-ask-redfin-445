import SwiftUI

struct MapShimmerOverlay: View {
    @State private var phase: CGFloat = -1.2

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let diag = sqrt(w * w + h * h)

            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0), location: 0.0),
                    .init(color: .white.opacity(0), location: 0.492),
                    .init(color: .white.opacity(0.06), location: 0.497),
                    .init(color: .white.opacity(0.16), location: 0.500),
                    .init(color: .white.opacity(0.06), location: 0.503),
                    .init(color: .white.opacity(0), location: 0.508),
                    .init(color: .white.opacity(0), location: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: diag * 2.0, height: diag * 2.0)
            .rotationEffect(.degrees(45))
            .offset(x: phase * diag)
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
            .onAppear {
                phase = -1.2
                withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

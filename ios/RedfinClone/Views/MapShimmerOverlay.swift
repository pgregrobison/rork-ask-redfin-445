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
                    .init(color: .white.opacity(0), location: 0.47),
                    .init(color: .white.opacity(0.22), location: 0.5),
                    .init(color: .white.opacity(0), location: 0.53),
                    .init(color: .white.opacity(0), location: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: diag * 1.6, height: diag * 1.6)
            .rotationEffect(.degrees(45))
            .offset(x: phase * diag)
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
            .onAppear {
                phase = -1.2
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

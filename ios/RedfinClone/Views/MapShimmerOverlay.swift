import SwiftUI

struct MapShimmerOverlay: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let diag = sqrt(w * w + h * h)

            ZStack {
                Color.white.opacity(0.08)
                    .blendMode(.plusLighter)

                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0), location: 0.0),
                        .init(color: .white.opacity(0.35), location: 0.45),
                        .init(color: .white.opacity(0.55), location: 0.5),
                        .init(color: .white.opacity(0.35), location: 0.55),
                        .init(color: .white.opacity(0), location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: diag * 0.6, height: diag * 1.4)
                .rotationEffect(.degrees(20))
                .offset(x: phase * diag)
                .blendMode(.plusLighter)
            }
            .compositingGroup()
            .allowsHitTesting(true)
            .onAppear {
                phase = -1
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
        }
        .ignoresSafeArea()
    }
}

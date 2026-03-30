import SwiftUI

struct InlineVoiceOrb: View {
    let isListening: Bool
    @State private var coreScale: CGFloat = 1.0
    @State private var coreGlow: Double = 0.4
    @State private var ring1Scale: CGFloat = 1.0
    @State private var ring1Opacity: Double = 0.2
    @State private var ring2Scale: CGFloat = 1.0
    @State private var ring2Opacity: Double = 0.12
    @State private var appeared: Bool = false

    private let accentColor = Theme.redfinGreenColor

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.03))
                    .frame(width: 140, height: 140)
                    .scaleEffect(ring2Scale)
                    .opacity(ring2Opacity)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accentColor.opacity(0.08), accentColor.opacity(0.02), .clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 70
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(ring1Scale)
                    .opacity(ring1Opacity)

                Circle()
                    .stroke(accentColor.opacity(0.12), lineWidth: 1)
                    .frame(width: 120, height: 120)
                    .scaleEffect(ring1Scale)
                    .opacity(ring1Opacity)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                accentColor.opacity(0.5),
                                accentColor.opacity(0.3),
                                accentColor.opacity(0.15)
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 45
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: accentColor.opacity(coreGlow * 0.35), radius: 25)
                    .shadow(color: accentColor.opacity(coreGlow * 0.12), radius: 50)
                    .scaleEffect(coreScale)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.25), .clear],
                            center: UnitPoint(x: 0.35, y: 0.3),
                            startRadius: 0,
                            endRadius: 35
                        )
                    )
                    .frame(width: 90, height: 90)
                    .scaleEffect(coreScale)
                    .blendMode(.overlay)
            }
            .scaleEffect(appeared ? 1 : 0.3)
            .opacity(appeared ? 1 : 0)

            Text(isListening ? "Listening…" : "Muted")
                .font(.caption)
                .foregroundStyle(.secondary)
                .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
            startAnimations()
        }
        .onChange(of: isListening) { _, _ in
            startAnimations()
        }
    }

    private func startAnimations() {
        let active = isListening

        withAnimation(.easeInOut(duration: active ? 0.9 : 2.0).repeatForever(autoreverses: true)) {
            coreScale = active ? 1.1 : 1.03
            coreGlow = active ? 0.65 : 0.3
        }

        withAnimation(.easeInOut(duration: active ? 1.1 : 2.4).repeatForever(autoreverses: true).delay(0.1)) {
            ring1Scale = active ? 1.15 : 1.04
            ring1Opacity = active ? 0.3 : 0.15
        }

        withAnimation(.easeInOut(duration: active ? 1.4 : 2.8).repeatForever(autoreverses: true).delay(0.25)) {
            ring2Scale = active ? 1.2 : 1.06
            ring2Opacity = active ? 0.18 : 0.08
        }
    }
}

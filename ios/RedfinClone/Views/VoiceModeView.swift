import SwiftUI

struct VoiceModeView: View {
    let onDismiss: () -> Void
    @State private var isListening: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.4
    @State private var outerRingScale: CGFloat = 1.0
    @State private var outerRingOpacity: Double = 0.3
    @State private var currentPromptIndex: Int = 0
    @State private var promptOpacity: Double = 1.0

    private let prompts = [
        "Tell me what you thought of that first home",
        "What's your budget range?",
        "Would you like to see more condos?",
        "How important is outdoor space to you?",
        "What neighborhood do you prefer?",
        "Are you looking for move-in ready?",
        "Do you need parking?",
        "How many bedrooms do you need?"
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 220, height: 220)
                        .scaleEffect(outerRingScale)
                        .opacity(outerRingOpacity)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.03),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 60,
                                endRadius: 110
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseScale)
                        .opacity(glowOpacity)

                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseScale * 0.95)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(white: 0.35),
                                    Color(white: 0.2),
                                    Color(white: 0.12)
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.white.opacity(0.15), radius: 30)
                        .scaleEffect(isListening ? 1.08 : 1.0)
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isListening.toggle()
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                Text(isListening ? "Listening…" : "Tap to speak")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 24)

                Text(prompts[currentPromptIndex])
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 28)
                    .opacity(promptOpacity)
                    .frame(height: 60)

                Spacer()

                if #available(iOS 26.0, *) {
                    Button {
                        onDismiss()
                    } label: {
                        Text("End Voice Mode")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.glass)
                    .padding(.bottom, 60)
                } else {
                    Button {
                        onDismiss()
                    } label: {
                        Text("End Voice Mode")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            startPulse()
            startOuterRing()
            startPromptCycling()
        }
        .onChange(of: isListening) { _, newValue in
            startPulse()
        }
    }

    private func startPulse() {
        let duration = isListening ? 0.6 : 1.4
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            pulseScale = isListening ? 1.15 : 1.06
            glowOpacity = isListening ? 0.6 : 0.35
        }
    }

    private func startOuterRing() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            outerRingScale = 1.2
            outerRingOpacity = 0.1
        }
    }

    private func startPromptCycling() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(4))
                withAnimation(.easeOut(duration: 0.3)) {
                    promptOpacity = 0
                }
                try? await Task.sleep(for: .seconds(0.35))
                currentPromptIndex = (currentPromptIndex + 1) % prompts.count
                withAnimation(.easeIn(duration: 0.3)) {
                    promptOpacity = 1
                }
            }
        }
    }
}

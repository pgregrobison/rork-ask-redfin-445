import SwiftUI

struct VoiceModeView: View {
    let onDismiss: () -> Void
    @State private var isListening: Bool = true
    @State private var coreScale: CGFloat = 1.0
    @State private var coreGlow: Double = 0.5
    @State private var ring1Scale: CGFloat = 1.0
    @State private var ring1Opacity: Double = 0.25
    @State private var ring2Scale: CGFloat = 1.0
    @State private var ring2Opacity: Double = 0.15
    @State private var ring3Scale: CGFloat = 1.0
    @State private var ring3Opacity: Double = 0.08
    @State private var currentPromptIndex: Int = 0
    @State private var promptOpacity: Double = 1.0
    @State private var appeared: Bool = false

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
            Color.black
                .ignoresSafeArea()
                .opacity(appeared ? 1 : 0)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.08), in: Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 8)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.02))
                        .frame(width: 280, height: 280)
                        .scaleEffect(ring3Scale)
                        .opacity(ring3Opacity)

                    Circle()
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                        .frame(width: 240, height: 240)
                        .scaleEffect(ring2Scale)
                        .opacity(ring2Opacity)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.06), .white.opacity(0.02), .clear],
                                center: .center,
                                startRadius: 70,
                                endRadius: 120
                            )
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(ring2Scale)
                        .opacity(ring2Opacity)

                    Circle()
                        .stroke(.white.opacity(0.12), lineWidth: 1.5)
                        .frame(width: 180, height: 180)
                        .scaleEffect(ring1Scale)
                        .opacity(ring1Opacity)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.08), .white.opacity(0.03), .clear],
                                center: .center,
                                startRadius: 50,
                                endRadius: 95
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(ring1Scale)
                        .opacity(ring1Opacity)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(white: 0.42),
                                    Color(white: 0.28),
                                    Color(white: 0.16)
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 65
                            )
                        )
                        .frame(width: 130, height: 130)
                        .shadow(color: .white.opacity(coreGlow * 0.4), radius: 40)
                        .shadow(color: .white.opacity(coreGlow * 0.15), radius: 80)
                        .scaleEffect(coreScale)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.3), .clear],
                                center: UnitPoint(x: 0.35, y: 0.3),
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 130, height: 130)
                        .scaleEffect(coreScale)
                        .blendMode(.overlay)
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                        isListening.toggle()
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                Text(isListening ? "Listening…" : "Tap to speak")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.top, 28)

                Text(prompts[currentPromptIndex])
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .opacity(promptOpacity)
                    .frame(height: 60)

                Spacer()

                endButton
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) { appeared = true }
            startAnimations()
            startPromptCycling()
        }
        .onChange(of: isListening) { _, _ in
            startAnimations()
        }
    }

    @ViewBuilder
    private var endButton: some View {
        if #available(iOS 26.0, *) {
            Button {
                onDismiss()
            } label: {
                Text("End")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.glass)
        } else {
            Button {
                onDismiss()
            } label: {
                Text("End")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.1), in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))
            }
        }
    }

    private func startAnimations() {
        let listening = isListening

        withAnimation(.easeInOut(duration: listening ? 0.8 : 2.0).repeatForever(autoreverses: true)) {
            coreScale = listening ? 1.12 : 1.03
            coreGlow = listening ? 0.7 : 0.35
        }

        withAnimation(.easeInOut(duration: listening ? 1.0 : 2.4).repeatForever(autoreverses: true).delay(0.1)) {
            ring1Scale = listening ? 1.18 : 1.05
            ring1Opacity = listening ? 0.35 : 0.2
        }

        withAnimation(.easeInOut(duration: listening ? 1.3 : 2.8).repeatForever(autoreverses: true).delay(0.25)) {
            ring2Scale = listening ? 1.22 : 1.08
            ring2Opacity = listening ? 0.2 : 0.1
        }

        withAnimation(.easeInOut(duration: listening ? 1.6 : 3.2).repeatForever(autoreverses: true).delay(0.4)) {
            ring3Scale = listening ? 1.3 : 1.1
            ring3Opacity = listening ? 0.12 : 0.05
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

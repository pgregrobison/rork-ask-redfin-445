import SwiftUI

// MARK: - Draft model

@Observable
final class OTOSetupDraft {
    var hasActiveDraft: Bool = false

    func clear() {
        hasActiveDraft = false
    }
}

// MARK: - Three dots loading indicator

struct ThreeDotsLoading: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .opacity(phase == i ? 1 : 0.35)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: false)) {
                phase = (phase + 1) % 3
            }
            Task { @MainActor in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(350))
                    withAnimation(.easeInOut(duration: 0.3)) {
                        phase = (phase + 1) % 3
                    }
                }
            }
        }
    }
}

// MARK: - Placeholder sheets

struct OTOSetupView: View {
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "house.and.flag")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                Text("Open to Offers Setup")
                    .font(.title2.bold())
                Text("This is a placeholder for the setup flow.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button {
                    onComplete()
                    dismiss()
                } label: {
                    Text("Activate")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 222/255, green: 51/255, blue: 65/255))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
            }
            .padding()
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct OTOSetupFlowView: View {
    @Bindable var draft: OTOSetupDraft
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                Text("Setup flow")
                    .font(.title2.bold())
                Text("Multi-step flow placeholder. Save a draft or activate.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                VStack(spacing: 12) {
                    Button {
                        draft.hasActiveDraft = true
                        dismiss()
                    } label: {
                        Text("Save draft")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .overlay(Capsule().stroke(Color.primary, lineWidth: 1))
                    }
                    Button {
                        draft.hasActiveDraft = false
                        onComplete()
                        dismiss()
                    } label: {
                        Text("Activate listing")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(red: 222/255, green: 51/255, blue: 65/255))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding()
            .navigationTitle("Open to Offers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct OTONextStepsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Label("Review your offers", systemImage: "envelope.open")
                Label("List on the open market", systemImage: "house")
                Label("Talk to an agent", systemImage: "person.2")
                Label("Pause your listing", systemImage: "pause.circle")
            }
            .navigationTitle("Next steps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct OTOOffersSheetView: View {
    let isOwnerB: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Submitted offers") {
                    offerRow(buyer: "Buyer in Ballard", price: "$892K")
                    offerRow(buyer: "Buyer in Fremont", price: "$1.01M")
                    offerRow(buyer: "Buyer in Queen Anne", price: "$938K")
                }
            }
            .navigationTitle("Offers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func offerRow(buyer: String, price: String) -> some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            VStack(alignment: .leading) {
                Text(buyer).font(.system(size: 15, weight: .semibold))
                Text("Submitted today").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(price).font(.system(size: 16, weight: .bold)).monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Asset placeholders (until art is provided)

struct MarketGaugePlaceholder: View {
    var body: some View {
        ZStack {
            // Semi-circle gauge arc
            Canvas { ctx, size in
                let rect = CGRect(x: 12, y: 0, width: size.width - 24, height: (size.width - 24))
                let center = CGPoint(x: rect.midX, y: rect.maxY)
                let radius = rect.width / 2

                let segments: [(start: Double, end: Double, color: Color)] = [
                    (180, 220, Color(red: 222/255, green: 51/255, blue: 65/255)),
                    (220, 260, Color(red: 232/255, green: 150/255, blue: 60/255)),
                    (260, 280, Color(red: 21/255, green: 114/255, blue: 122/255)),
                    (280, 320, Color(red: 232/255, green: 150/255, blue: 60/255)),
                    (320, 360, Color(red: 1/255, green: 120/255, blue: 62/255)),
                ]
                for seg in segments {
                    var path = Path()
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(seg.start),
                        endAngle: .degrees(seg.end),
                        clockwise: false
                    )
                    ctx.stroke(path, with: .color(seg.color), style: StrokeStyle(lineWidth: 18, lineCap: .butt))
                }

                // Needle pointing roughly to "balanced" middle
                var needle = Path()
                needle.move(to: center)
                let needleAngle: Double = 270 * .pi / 180
                let nx = center.x + cos(needleAngle) * (radius - 4)
                let ny = center.y + sin(needleAngle) * (radius - 4)
                needle.addLine(to: CGPoint(x: nx, y: ny))
                ctx.stroke(needle, with: .color(Color(red: 17/255, green: 17/255, blue: 17/255)), style: StrokeStyle(lineWidth: 3, lineCap: .round))

                ctx.fill(Path(ellipseIn: CGRect(x: center.x - 7, y: center.y - 7, width: 14, height: 14)),
                         with: .color(Color(red: 17/255, green: 17/255, blue: 17/255)))
            }
            .frame(height: 130)

            VStack {
                Spacer()
                HStack {
                    Text("Buyer's").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text("Balanced").font(.caption.weight(.semibold))
                    Spacer()
                    Text("Seller's").font(.caption).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ReimagineSpacePlaceholder: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 235/255, green: 220/255, blue: 200/255),
                    Color(red: 200/255, green: 215/255, blue: 200/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                Text("Reimagine your space")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Visualize updates with AI")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

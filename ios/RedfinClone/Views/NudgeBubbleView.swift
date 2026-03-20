import SwiftUI

struct NudgeBubbleView: View {
    let text: String
    @State private var visibleCharCount: Int = 0
    @State private var isVisible: Bool = false

    var body: some View {
        if isVisible {
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(String(text.prefix(visibleCharCount)))
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .bottom)))
        }
    }

    func startAnimation() -> Self {
        var copy = self
        copy._isVisible = State(initialValue: false)
        return copy
    }

    func onAppearAnimate() {
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isVisible = true
            }
            for i in 1...text.count {
                try? await Task.sleep(for: .milliseconds(40))
                visibleCharCount = i
            }
            try? await Task.sleep(for: .seconds(8))
            withAnimation(.easeOut(duration: 0.3)) {
                isVisible = false
            }
        }
    }
}

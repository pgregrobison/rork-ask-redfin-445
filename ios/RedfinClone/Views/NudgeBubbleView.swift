import SwiftUI

struct NudgeBubbleView: View {
    let text: String
    @State private var visibleCharCount: Int = 0
    @State private var isVisible: Bool = false

    var body: some View {
        if isVisible {
            Text(String(text.prefix(visibleCharCount)))
                .font(Theme.Typography.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            .padding(.horizontal, Theme.Spacing.sm + 2)
            .padding(.vertical, Theme.Spacing.xs + 2)
            .background(Theme.Colors.secondaryBackground)
            .clipShape(.rect(cornerRadius: Theme.Radius.medium + 2))
            .shadow(color: Theme.Shadow.mediumColor, radius: Theme.Shadow.mediumRadius, y: Theme.Shadow.mediumY)
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

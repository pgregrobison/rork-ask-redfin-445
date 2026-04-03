import SwiftUI

struct ThinkingIndicator: View {
    let label: String
    @State private var isAnimating: Bool = false

    var body: some View {
        HStack(spacing: Theme.Spacing.xxs + 2) {
            Text(label)
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: label)

            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: 5, height: 5)
                        .offset(y: isAnimating ? -6 : 0)
                        .animation(
                            .easeInOut(duration: 0.45)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                            value: isAnimating
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.md)
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }
    }
}

import SwiftUI

struct ThinkingIndicator: View {
    let label: String
    @State private var activeDot: Int = -1

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
                        .offset(y: activeDot == index ? -6 : 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.md)
        .task {
            let step: Duration = .milliseconds(220)
            var i = 0
            while !Task.isCancelled {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                    activeDot = i
                }
                try? await Task.sleep(for: step)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    activeDot = -1
                }
                try? await Task.sleep(for: .milliseconds(120))
                i = (i + 1) % 3
            }
        }
    }
}

import SwiftUI

@available(iOS 26.0, *)
struct AskRedfinAccessoryBar: View {
    let onTap: () -> Void
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement
    @Environment(\.askRedfinContext) private var contextModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var index: Int = 0

    private var suggestions: [String] {
        contextModel.suggestions(for: contextModel.context)
    }

    private var currentText: String {
        let arr = suggestions
        guard !arr.isEmpty else { return "Ask anything..." }
        return arr[index % arr.count]
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Text(currentText)
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .contentTransition(.opacity)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: currentText)

                HStack {
                    Image(systemName: "sparkle")
                        .font(.system(size: Theme.ButtonSize.iconSize, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .padding(.leading, Theme.Spacing.md)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onChange(of: contextModel.context) { _, _ in
            index = 0
        }
        .task(id: contextModel.context) {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3.5))
                if Task.isCancelled { return }
                let count = suggestions.count
                guard count > 1 else { continue }
                index = (index + 1) % count
            }
        }
    }
}

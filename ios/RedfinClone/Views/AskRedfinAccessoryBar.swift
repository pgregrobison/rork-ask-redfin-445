import SwiftUI

@available(iOS 26.0, *)
struct AskRedfinAccessoryBar: View {
    let onTap: () -> Void
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Text("Ask anything...")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack {
                    Image(systemName: "sparkle")
                        .font(.system(size: Theme.ButtonSize.iconSize, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .padding(.leading, placement == .inline ? Theme.Spacing.xs : Theme.Spacing.md)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

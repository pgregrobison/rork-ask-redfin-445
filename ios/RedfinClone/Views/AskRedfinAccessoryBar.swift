import SwiftUI

@available(iOS 26.0, *)
struct AskRedfinAccessoryBar: View {
    let onTap: () -> Void
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.xs) {
                if placement == .inline {
                    Image(systemName: "sparkle")
                        .font(.system(size: Theme.ButtonSize.iconSize, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("Ask or search anything")
                        .font(Theme.Typography.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.leading, Theme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "sparkle")
                        .font(.system(size: Theme.ButtonSize.iconSize, weight: .bold))
                        .foregroundStyle(Theme.Colors.invertedPrimary)
                        .frame(width: Theme.ButtonSize.circleSize, height: Theme.ButtonSize.circleSize)
                        .background(Color.primary)
                        .clipShape(Circle())
                        .padding(.trailing, 2)
                }
            }
            .padding(.vertical, placement == .inline ? 0 : Theme.Spacing.xxs)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

struct MapPinView: View {
    let listing: Listing
    let isSelected: Bool
    let isSeen: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(listing.formattedPrice)
            .font(.system(size: Theme.IconSize.mapPin, weight: .bold))
            .tracking(-0.3)
            .foregroundStyle(textColor)
            .padding(.horizontal, Theme.MapPin.horizontalPadding)
            .padding(.vertical, Theme.Spacing.xxs + 2)
            .background(backgroundColor, in: Capsule())
            .shadow(color: Theme.Shadow.subtleColor, radius: Theme.Shadow.subtleRadius, y: Theme.Shadow.subtleY)
            .padding(Theme.MapPin.outerPadding)
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.2), value: isSelected)
            .animation(.easeInOut(duration: 0.2), value: isSeen)
    }

    private var backgroundColor: Color {
        if isSelected {
            return colorScheme == .dark
                ? Theme.Colors.MapPin.selectedDark
                : Theme.Colors.MapPin.selectedLight
        }
        if isSeen {
            return colorScheme == .dark
                ? Theme.Colors.MapPin.seenDark
                : Theme.Colors.MapPin.seenLight
        }
        return colorScheme == .dark ? .black : .white
    }

    private var textColor: Color {
        if isSelected {
            return .white
        }
        if isSeen {
            return colorScheme == .dark ? .white : .black
        }
        return colorScheme == .dark ? .white : .black
    }
}

import SwiftUI

struct MapPinView: View {
    let listing: Listing
    let isSelected: Bool
    let isSeen: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(listing.formattedPrice)
            .font(.system(size: 13, weight: .bold))
            .tracking(-0.3)
            .foregroundStyle(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, Theme.Spacing.xxs + 2)
            .background(backgroundColor, in: Capsule())
            .shadow(color: Theme.Shadow.subtleColor, radius: Theme.Shadow.subtleRadius, y: Theme.Shadow.subtleY)
            .padding(2)
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

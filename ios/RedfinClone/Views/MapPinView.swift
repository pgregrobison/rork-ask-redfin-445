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
            .padding(.vertical, 6)
            .background(backgroundColor, in: Capsule())
            .shadow(color: .black.opacity(0.22), radius: 4, y: 2)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
            .animation(.easeInOut(duration: 0.2), value: isSeen)
    }

    private var backgroundColor: Color {
        if isSelected {
            return colorScheme == .dark
                ? Color(red: 224/255, green: 58/255, blue: 58/255)
                : Color(red: 200/255, green: 32/255, blue: 33/255)
        }
        if isSeen {
            return colorScheme == .dark
                ? Color(red: 44/255, green: 44/255, blue: 46/255)
                : Color(red: 216/255, green: 216/255, blue: 220/255)
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

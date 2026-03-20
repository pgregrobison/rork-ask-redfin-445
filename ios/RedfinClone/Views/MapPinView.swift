import SwiftUI

struct MapPinView: View {
    let listing: Listing
    let isSelected: Bool
    let isSeen: Bool

    var body: some View {
        Text(listing.formattedPrice)
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(pinColor, in: Capsule())
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var pinColor: Color {
        if isSelected {
            return Color(white: 0.15)
        }
        if isSeen {
            return Color(white: 0.45)
        }
        return Color(white: 0.15)
    }
}

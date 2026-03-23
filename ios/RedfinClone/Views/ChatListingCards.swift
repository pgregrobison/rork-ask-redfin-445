import SwiftUI

struct ChatListingCards: View {
    let listingIds: [String]
    let allListings: [Listing]
    let onShowOnMap: ([Listing]) -> Void
    let onListingTap: (Listing) -> Void

    private var matchedListings: [Listing] {
        listingIds.compactMap { id in
            allListings.first { $0.id == id }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(matchedListings) { listing in
                        Button { onListingTap(listing) } label: {
                            HomeCard(
                                listing: listing,
                                size: .medium,
                                badge: listing.primaryBadge
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)

            if !matchedListings.isEmpty {
                Button {
                    onShowOnMap(matchedListings)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "map")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        Text("Show on map")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.12), in: .rect(cornerRadius: 14))
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

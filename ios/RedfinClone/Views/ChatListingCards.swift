import SwiftUI

struct ChatListingCards: View {
    let listingIds: [String]
    let allListings: [Listing]
    let savedListingIDs: Set<String>
    let onToggleSave: (Listing) -> Void
    let onShowOnMap: ([Listing]) -> Void
    let onListingTap: (Listing) -> Void
    @Binding var scrolledListingID: String?
    @State private var hasAppeared: Bool = false

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
                                isSaved: savedListingIDs.contains(listing.id),
                                badge: listing.primaryBadge,
                                onToggleSave: { onToggleSave(listing) }
                            )
                        }
                        .buttonStyle(.plain)
                        .id(listing.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledListingID)
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)

            if !matchedListings.isEmpty {
                Button {
                    let nyListings = matchedListings.filter { $0.state == "NY" }
                    onShowOnMap(nyListings.isEmpty ? matchedListings : nyListings)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "map")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        Text("Show on map")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primary, in: Capsule())
                }
                .padding(.horizontal, 16)
            }
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 16)
        .onAppear {
            guard !hasAppeared else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                hasAppeared = true
            }
        }
    }
}

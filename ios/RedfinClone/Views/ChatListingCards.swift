import SwiftUI

struct ChatListingCards: View {
    let listingIds: [String]
    let allListings: [Listing]
    let savedListingIDs: Set<String>
    let onToggleSave: (Listing) -> Void
    let onShowOnMap: ([Listing]) -> Void
    let onListingTap: (Listing) -> Void
    @Binding var scrolledListingID: String?
    var zoomNamespace: Namespace.ID?
    @State private var hasAppeared: Bool = false

    private var matchedListings: [Listing] {
        listingIds.compactMap { id in
            allListings.first { $0.id == id }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            ScrollView(.horizontal) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(matchedListings) { listing in
                        Button { onListingTap(listing) } label: {
                            HomeCard(
                                listing: listing,
                                size: .compact(width: 300),
                                isSaved: savedListingIDs.contains(listing.id),
                                badge: listing.primaryBadge,
                                onToggleSave: { onToggleSave(listing) }
                            )
                        }
                        .buttonStyle(.plain)
                        .id(listing.id)
                        .matchedTransitionSourceIfAvailable(id: listing.id, in: zoomNamespace)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledListingID)
            .contentMargins(.horizontal, Theme.Spacing.md)
            .scrollIndicators(.hidden)

            if !matchedListings.isEmpty {
                Button {
                    let nyListings = matchedListings.filter { $0.state == "NY" }
                    onShowOnMap(nyListings.isEmpty ? matchedListings : nyListings)
                } label: {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "map")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        Text("Show on map")
                    }
                }
                .buttonStyle(.primary)
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : Theme.Spacing.md)
        .onAppear {
            guard !hasAppeared else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                hasAppeared = true
            }
        }
    }
}

import SwiftUI

struct FindListView: View {
    @Bindable var viewModel: ListingsViewModel
    var zoomNamespace: Namespace.ID
    let onListingTap: (Listing) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(viewModel.sortedListings) { listing in
                    Button {
                        onListingTap(listing)
                    } label: {
                        HomeCard(
                            listing: listing,
                            size: .medium,
                            isSaved: viewModel.isSaved(listing),
                            badge: listing.primaryBadge,
                            onToggleSave: { viewModel.toggleSaved(listing) }
                        )
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: listing.id, in: zoomNamespace)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.tabBarClearance)
        }
        .background(Theme.Colors.background)
    }

}

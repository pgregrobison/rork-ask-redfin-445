import SwiftUI

struct FindListView: View {
    @Bindable var viewModel: ListingsViewModel
    var zoomNamespace: Namespace.ID
    let onListingTap: (Listing) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.sortedListings) { listing in
                    Button {
                        onListingTap(listing)
                    } label: {
                        HomeCard(
                            listing: listing,
                            size: .large,
                            isSaved: viewModel.isSaved(listing),
                            badge: listing.primaryBadge,
                            onToggleSave: { viewModel.toggleSaved(listing) }
                        )
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: listing.id, in: zoomNamespace)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 52)
            .padding(.bottom, 100)
        }
        .background(Color(.systemBackground))
    }

}

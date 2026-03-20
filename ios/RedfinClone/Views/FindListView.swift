import SwiftUI

struct FindListView: View {
    @Bindable var viewModel: ListingsViewModel
    let onListingTap: (Listing) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.sortedListings) { listing in
                    Button {
                        onListingTap(listing)
                    } label: {
                        ListingListCard(
                            listing: listing,
                            isSaved: viewModel.isSaved(listing),
                            onToggleSave: { viewModel.toggleSaved(listing) }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .background(Color(.systemBackground))
    }
}

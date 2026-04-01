import SwiftUI

struct FindListView: View {
    @Bindable var viewModel: ListingsViewModel
    let onListingTap: (Listing) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                HStack {
                    Spacer()
                    sortMenu
                }

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
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .background(Color(.systemBackground))
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 13, weight: .semibold))
                Text("Sort")
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Capsule())
        }
    }
}

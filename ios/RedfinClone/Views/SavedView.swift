import SwiftUI

struct SavedView: View {
    let viewModel: ListingsViewModel
    let onListingTap: (Listing) -> Void

    var body: some View {
        Group {
            if viewModel.savedListings.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.savedListings) { listing in
                            Button { onListingTap(listing) } label: {
                                HomeCard(
                                    listing: listing,
                                    size: .large,
                                    isSaved: true,
                                    badge: listing.isHotHome ? .hot : nil,
                                    onToggleSave: { viewModel.toggleSaved(listing) }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .frame(width: 80, height: 80)
                .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 20))

            Text("No saved homes yet")
                .font(.title3.bold())

            Text("Tap the heart icon on any listing to save it here for quick access.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

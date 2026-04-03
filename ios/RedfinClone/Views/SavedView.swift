import SwiftUI

struct SavedView: View {
    let viewModel: ListingsViewModel
    var zoomNamespace: Namespace.ID
    let onListingTap: (Listing) -> Void

    var body: some View {
        Group {
            if viewModel.savedListings.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(viewModel.savedListings) { listing in
                            Button { onListingTap(listing) } label: {
                                HomeCard(
                                    listing: listing,
                                    size: .medium,
                                    isSaved: true,
                                    badge: listing.primaryBadge,
                                    onToggleSave: { viewModel.toggleSaved(listing) }
                                )
                            }
                            .buttonStyle(.plain)
                            .matchedTransitionSource(id: listing.id, in: zoomNamespace)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.sm)
                    .padding(.bottom, Theme.Spacing.tabBarClearance)
                }
            }
        }
        .background(Theme.Colors.background)
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
        VStack(spacing: Theme.Spacing.md) {
            Spacer()
            Image(systemName: "heart")
                .font(Theme.Typography.decorativeXL)
                .foregroundStyle(.secondary)
                .frame(width: 80, height: 80)
                .background(Theme.Colors.secondaryBackground, in: .rect(cornerRadius: Theme.Radius.xl))

            Text("No saved homes yet")
                .font(Theme.Typography.cardTitle)

            Text("Tap the heart icon on any listing to save it here for quick access.")
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xxl + 8)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

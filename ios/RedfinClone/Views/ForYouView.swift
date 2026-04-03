import SwiftUI

struct ForYouView: View {
    let viewModel: ListingsViewModel
    var zoomNamespace: Namespace.ID
    let onListingTap: (Listing) -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if !viewModel.hotHomes.isEmpty {
                    sectionHeader(title: "Hot Homes", subtitle: "Selling fast in NYC")
                    hotHomesScroll
                }

                if !viewModel.justListed.isEmpty {
                    sectionHeader(title: "Just Listed", subtitle: "New on the market")
                    justListedScroll
                }

                marketInsightCard
            }
            .padding(.bottom, 100)
        }
        .background(Theme.Colors.background)
        .navigationTitle("For You")
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

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(Theme.Typography.sectionTitle)
            Text(subtitle)
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private var hotHomesScroll: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                ForEach(viewModel.hotHomes) { listing in
                    Button { onListingTap(listing) } label: {
                        HomeCard(
                            listing: listing,
                            size: .compact(width: 280),
                            isSaved: viewModel.isSaved(listing),
                            badge: listing.primaryBadge,
                            onToggleSave: { viewModel.toggleSaved(listing) }
                        )
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: listing.id, in: zoomNamespace)
                }
            }
        }
        .contentMargins(.horizontal, Theme.Spacing.lg)
        .scrollIndicators(.hidden)
    }

    private var justListedScroll: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                ForEach(viewModel.justListed) { listing in
                    Button { onListingTap(listing) } label: {
                        HomeCard(
                            listing: listing,
                            size: .compact(width: 260),
                            isSaved: viewModel.isSaved(listing),
                            badge: listing.primaryBadge,
                            onToggleSave: { viewModel.toggleSaved(listing) }
                        )
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: listing.id, in: zoomNamespace)
                }
            }
        }
        .contentMargins(.horizontal, Theme.Spacing.lg)
        .scrollIndicators(.hidden)
    }

    private var marketInsightCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: 10) {
                Image(systemName: "chart.bar")
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Market Insight")
                    .font(Theme.Typography.headline)
            }

            Text("NYC Housing Market Trends")
                .font(Theme.Typography.cardTitle)

            Text("The NYC metro housing market remains competitive with a median home price of $1.2M, up 4.2% year-over-year. Inventory is tight with homes spending an average of 21 days on market. Manhattan condos and Brooklyn brownstones continue to see the strongest buyer demand, while Queens offers the best value per square foot.")
                .font(Theme.Typography.secondary)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(.rect(cornerRadius: Theme.Radius.large))
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

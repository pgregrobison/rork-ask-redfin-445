import SwiftUI

struct ForYouView: View {
    let viewModel: ListingsViewModel
    var zoomNamespace: Namespace.ID
    let isActive: Bool
    let onProfileTap: () -> Void
    let onListingTap: (Listing) -> Void
    var hideProfileButton: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if !viewModel.hotHomes.isEmpty {
                    sectionHeader(title: "Hot Homes", subtitle: "Selling fast in NYC")
                    carousel(listings: viewModel.hotHomes, cardWidth: 280)
                }

                if !viewModel.justListed.isEmpty {
                    sectionHeader(title: "Just Listed", subtitle: "New on the market")
                    carousel(listings: viewModel.justListed, cardWidth: 260)
                }

                if !viewModel.openHousesThisWeekend.isEmpty {
                    sectionHeader(title: "Open Houses", subtitle: "Tour this weekend")
                    carousel(listings: viewModel.openHousesThisWeekend, cardWidth: 260)
                }

                if !viewModel.recentlyReducedHomes.isEmpty {
                    sectionHeader(title: "Price Drops", subtitle: "Recently reduced")
                    carousel(listings: viewModel.recentlyReducedHomes, cardWidth: 260)
                }

                if !viewModel.luxuryHomes.isEmpty {
                    sectionHeader(title: "Luxury Homes", subtitle: "$2M and up")
                    carousel(listings: viewModel.luxuryHomes, cardWidth: 280)
                }

                if !viewModel.bestValueHomes.isEmpty {
                    sectionHeader(title: "Best Value", subtitle: "Lowest price per sq ft")
                    carousel(listings: viewModel.bestValueHomes, cardWidth: 260)
                }

                if !viewModel.comingSoonHomes.isEmpty {
                    sectionHeader(title: "Coming Soon", subtitle: "Hitting the market soon")
                    carousel(listings: viewModel.comingSoonHomes, cardWidth: 260)
                }

                marketInsightCard
            }
            .padding(.bottom, Theme.Spacing.tabBarClearance)
        }
        .background(Theme.Colors.background)
        .navigationTitle(isActive ? "For You" : "")
        .navigationBarTitleDisplayMode(isActive ? .large : .inline)
        .toolbar {
            if isActive && !hideProfileButton {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { onProfileTap() } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    }
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

    private func carousel(listings: [Listing], cardWidth: CGFloat) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                ForEach(listings) { listing in
                    Button { onListingTap(listing) } label: {
                        HomeCard(
                            listing: listing,
                            size: .compact(width: cardWidth),
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

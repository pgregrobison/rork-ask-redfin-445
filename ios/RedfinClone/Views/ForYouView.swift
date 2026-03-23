import SwiftUI

struct ForYouView: View {
    let viewModel: ListingsViewModel
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
        .background(Color(.systemBackground))
        .navigationTitle("For You")
        .navigationBarTitleDisplayMode(.large)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
    }

    private var hotHomesScroll: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                ForEach(viewModel.hotHomes) { listing in
                    Button { onListingTap(listing) } label: {
                        hotHomeCard(listing)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, 20)
        .scrollIndicators(.hidden)
    }

    private func hotHomeCard(_ listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(.tertiarySystemBackground)
                .frame(width: 280, height: 180)
                .overlay {
                    AsyncImage(url: URL(string: listing.photos.first ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        }
                    }
                    .allowsHitTesting(false)
                }
                .clipShape(.rect(topLeadingRadius: 14, topTrailingRadius: 14))
                .overlay(alignment: .topLeading) {
                    Text("HOT")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(white: 0.15), in: .rect(cornerRadius: 6))
                        .padding(10)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(listing.formattedFullPrice)
                    .font(.headline)

                HStack(spacing: 6) {
                    Text("\(listing.beds) bd")
                    Text("·")
                    Text("\(listing.bathsFormatted) ba")
                    Text("·")
                    Text("\(listing.sqft.formatted()) sq ft")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(listing.address + ", " + listing.city)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(12)
        }
        .frame(width: 280)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var justListedScroll: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                ForEach(viewModel.justListed) { listing in
                    Button { onListingTap(listing) } label: {
                        justListedCard(listing)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, 20)
        .scrollIndicators(.hidden)
    }

    private func justListedCard(_ listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(.tertiarySystemBackground)
                .frame(width: 260, height: 160)
                .overlay {
                    AsyncImage(url: URL(string: listing.photos.first ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        }
                    }
                    .allowsHitTesting(false)
                }
                .clipShape(.rect(topLeadingRadius: 14, topTrailingRadius: 14))
                .overlay(alignment: .topLeading) {
                    Text("\(listing.daysOnMarket)d ago")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.redfinGreenColor, in: .rect(cornerRadius: 6))
                        .padding(10)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(listing.formattedFullPrice)
                    .font(.headline)

                HStack(spacing: 6) {
                    Text("\(listing.beds) bd")
                    Text("·")
                    Text("\(listing.bathsFormatted) ba")
                    Text("·")
                    Text("\(listing.sqft.formatted()) sq ft")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(listing.address + ", " + listing.city)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(12)
        }
        .frame(width: 260)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var marketInsightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "chart.bar")
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Market Insight")
                    .font(.headline)
            }

            Text("NYC Housing Market Trends")
                .font(.title3.bold())

            Text("The NYC metro housing market remains competitive with a median home price of $1.2M, up 4.2% year-over-year. Inventory is tight with homes spending an average of 21 days on market. Manhattan condos and Brooklyn brownstones continue to see the strongest buyer demand, while Queens offers the best value per square foot.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

import SwiftUI

struct ChatListingCards: View {
    let listingIds: [String]
    let allListings: [Listing]
    let onShowOnMap: ([Listing]) -> Void
    let onListingTap: (Listing) -> Void

    private var matchedListings: [Listing] {
        listingIds.compactMap { id in
            allListings.first { $0.id == id }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(matchedListings) { listing in
                        Button { onListingTap(listing) } label: {
                            listingCard(listing)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)

            if !matchedListings.isEmpty {
                Button {
                    onShowOnMap(matchedListings)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "map")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Show on map")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(white: 0.12), in: .rect(cornerRadius: 14))
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func listingCard(_ listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(.secondarySystemBackground)
                .frame(width: 300, height: 220)
                .overlay {
                    AsyncImage(url: URL(string: listing.photos.first ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        }
                    }
                    .allowsHitTesting(false)
                }
                .clipShape(.rect(topLeadingRadius: 12, topTrailingRadius: 12))
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 28))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color(white: 0.2))
                        .padding(10)
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(listing.formattedFullPrice)
                        .font(.title3.bold())
                    Spacer()
                    Image(systemName: "heart")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    Text("\(listing.beds) bd")
                    Text("\(listing.bathsFormatted) ba")
                    Text("\(listing.sqft.formatted()) sq ft")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(listing.fullAddress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if !listing.tags.isEmpty {
                    Text(listing.tags.prefix(3).joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .frame(width: 300)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

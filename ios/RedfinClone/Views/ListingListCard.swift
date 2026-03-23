import SwiftUI

struct ListingListCard: View {
    let listing: Listing
    let isSaved: Bool
    let onToggleSave: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            photoSection
            infoSection
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))

    }

    private var photoSection: some View {
        Color(.tertiarySystemBackground)
            .frame(height: 240)
            .overlay {
                AsyncImage(url: URL(string: listing.photos.first ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    }
                }
                .allowsHitTesting(false)
            }
            .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "mappin.circle")
                    .font(.system(size: Theme.IconSize.small, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
                    .padding(12)
            }
            .overlay(alignment: .topLeading) {
                if listing.isHotHome {
                    Text("HOT HOME")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(white: 0.15), in: .rect(cornerRadius: 6))
                        .padding(12)
                }
            }
    }

    private var cardActions: some View {
        HStack(spacing: 4) {
            ShareLink(item: listing.shareText) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: Theme.IconSize.small, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: Theme.IconSize.smallTap, height: Theme.IconSize.smallTap)
                    .contentShape(Rectangle())
            }

            Button(action: onToggleSave) {
                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .font(.system(size: Theme.IconSize.small, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(isSaved ? .primary : .secondary)
                    .frame(width: Theme.IconSize.smallTap, height: Theme.IconSize.smallTap)
                    .contentShape(Rectangle())
            }
            .sensoryFeedback(.selection, trigger: isSaved)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(listing.formattedFullPrice)
                .font(.title2.bold())

            HStack(spacing: 8) {
                Text("\(listing.beds) bd")
                Text("·")
                Text("\(listing.bathsFormatted) ba")
                Text("·")
                Text("\(listing.sqft.formatted()) sq ft")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(listing.fullAddress)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !listing.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(listing.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .overlay(alignment: .topTrailing) {
            cardActions
                .padding(.top, 4)
                .padding(.trailing, 4)
        }
    }
}

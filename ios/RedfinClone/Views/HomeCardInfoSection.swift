import SwiftUI

struct HomeCardInfoSection: View {
    let listing: Listing
    let size: HomeCardSize
    var isSaved: Bool = false
    var onToggleSave: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: size.fixedWidth != nil ? 6 : 8) {
            Text(listing.formattedFullPrice)
                .font(size.priceFont)

            statsRow

            Text(listing.fullAddress)
                .font(size.addressFont)
                .foregroundStyle(.secondary)
                .lineLimit(size.fixedWidth != nil ? 1 : nil)

            if !listing.tags.isEmpty {
                tagsRow
            }
        }
        .padding(size.infoPadding)
        .overlay(alignment: .topTrailing) {
            cardActions
                .padding(.top, 4)
                .padding(.trailing, 4)
        }
    }

    private var statsRow: some View {
        HStack(spacing: size.fixedWidth != nil ? 6 : 8) {
            Text("\(listing.beds) bd")
            Text("·")
            Text("\(listing.bathsFormatted) ba")
            Text("·")
            Text("\(listing.sqft.formatted()) sq ft")
        }
        .font(size.statsFont)
        .foregroundStyle(.secondary)
    }

    private var tagsRow: some View {
        HStack(spacing: 6) {
            ForEach(listing.tags.prefix(3), id: \.self) { tag in
                Text(tag)
                    .font(size.tagFont)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
            }
        }
    }

    private var cardActions: some View {
        HStack(spacing: 4) {
            if size.showShareAction {
                ShareLink(item: listing.shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: Theme.IconSize.small, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: Theme.IconSize.smallTap, height: Theme.IconSize.smallTap)
                        .contentShape(Rectangle())
                }
            }

            if let onToggleSave {
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
    }
}

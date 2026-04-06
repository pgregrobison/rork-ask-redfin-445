import SwiftUI

struct HomeCardInfoSection: View {
    let listing: Listing
    let size: HomeCardSize
    var isSaved: Bool = false
    var onToggleSave: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: size.fixedWidth != nil ? Theme.Spacing.xxs + 2 : Theme.Spacing.xs) {
            Text(listing.formattedFullPrice)
                .font(size.priceFont)

            statsRow

            Text(listing.fullAddress)
                .font(size.addressFont)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if !listing.tags.isEmpty {
                tagsRow
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(size.infoPadding)
        .overlay(alignment: .topTrailing) {
            cardActions
                .padding(.top, size.fixedWidth == nil ? Theme.Spacing.xs : Theme.Spacing.xxs)
                .padding(.trailing, Theme.Spacing.sm)
        }
    }

    private var statsRow: some View {
        HStack(spacing: size.fixedWidth != nil ? Theme.Spacing.xxs + 2 : Theme.Spacing.xs) {
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
        TagRow(tags: listing.tags)
    }

    private var cardActions: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            if size.showShareAction {
                ShareLink(item: listing.shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: Theme.IconSize.mediumTap, height: Theme.IconSize.mediumTap)
                        .contentShape(Rectangle())
                }
                .sensoryFeedback(.selection, trigger: false)
            }

            if let onToggleSave {
                Button(action: onToggleSave) {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .contentTransition(.symbolEffect(.replace))
                        .foregroundStyle(isSaved ? .red : .secondary)
                        .frame(width: Theme.IconSize.mediumTap, height: Theme.IconSize.mediumTap)
                        .contentShape(Rectangle())
                }
                .sensoryFeedback(.selection, trigger: isSaved)
            }
        }
    }
}

import SwiftUI

enum HomeCardSize {
    case large
    case medium
    case compact(width: CGFloat = 280)

    var photoHeight: CGFloat {
        switch self {
        case .large: Theme.CardSize.PhotoHeight.large
        case .medium: Theme.CardSize.PhotoHeight.medium
        case .compact: Theme.CardSize.PhotoHeight.compact
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .large: Theme.Radius.large
        case .medium, .compact: 14
        }
    }

    var fixedWidth: CGFloat? {
        switch self {
        case .large: nil
        case .medium: Theme.CardSize.FixedWidth.medium
        case .compact(let width): width
        }
    }

    var priceFont: Font {
        switch self {
        case .large: Theme.Typography.sectionTitle
        case .medium: Theme.Typography.cardTitle
        case .compact: Theme.Typography.headline
        }
    }

    var statsFont: Font {
        switch self {
        case .large: Theme.Typography.secondary
        case .medium: Theme.Typography.secondary
        case .compact: Theme.Typography.caption
        }
    }

    var addressFont: Font {
        switch self {
        case .large: Theme.Typography.secondary
        case .medium: Theme.Typography.secondary
        case .compact: Theme.Typography.caption
        }
    }

    var tagFont: Font {
        switch self {
        case .large: Theme.Typography.caption
        case .medium, .compact: Theme.Typography.micro
        }
    }

    var infoPadding: EdgeInsets {
        switch self {
        case .large: Theme.CardSize.InfoPadding.large
        case .medium: Theme.CardSize.InfoPadding.medium
        case .compact: Theme.CardSize.InfoPadding.compact
        }
    }

    var showShareAction: Bool {
        switch self {
        case .large: true
        case .medium, .compact: false
        }
    }
}

struct HomeCard: View {
    let listing: Listing
    let size: HomeCardSize
    var isSaved: Bool = false
    var badge: HomeCardBadge? = nil
    var onToggleSave: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            photoSection
            HomeCardInfoSection(
                listing: listing,
                size: size,
                isSaved: isSaved,
                onToggleSave: onToggleSave
            )
        }
        .frame(width: size.fixedWidth)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(.rect(cornerRadius: size.cornerRadius))
    }

    private var photoSection: some View {
        Theme.Colors.tertiaryBackground
            .frame(height: size.photoHeight)
            .overlay {
                AsyncImage(url: URL(string: listing.photos.first ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    }
                }
                .allowsHitTesting(false)
            }
            .clipShape(.rect(topLeadingRadius: size.cornerRadius, topTrailingRadius: size.cornerRadius))
            .overlay(alignment: .topLeading) {
                if let badge {
                    badgeView(badge)
                        .padding(size.fixedWidth != nil ? 10 : Theme.Spacing.sm)
                }
            }
    }

    private func badgeView(_ badge: HomeCardBadge) -> some View {
        Text(badge.text)
            .font(Theme.Typography.micro.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.vertical, Theme.Spacing.xxs)
            .background(badge.color, in: .rect(cornerRadius: Theme.Radius.small))
    }
}

enum HomeCardBadge {
    case hot
    case listedByRedfin
    case compassComingSoon
    case daysAgo(Int)

    var text: String {
        switch self {
        case .hot: "HOT HOME"
        case .listedByRedfin: "LISTED BY REDFIN"
        case .compassComingSoon: "COMPASS COMING SOON"
        case .daysAgo(let days): "\(days)d ago"
        }
    }

    var color: Color {
        switch self {
        case .hot: Theme.Colors.Badge.hot
        case .listedByRedfin: Theme.Colors.Badge.listedByRedfin
        case .compassComingSoon: Theme.Colors.Badge.compass
        case .daysAgo: Theme.Colors.Badge.daysAgo
        }
    }
}

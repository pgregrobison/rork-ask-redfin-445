import SwiftUI

enum HomeCardSize {
    case large
    case medium
    case compact(width: CGFloat = 280)

    var photoHeight: CGFloat {
        switch self {
        case .large: 240
        case .medium: 220
        case .compact: 180
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .large: 16
        case .medium, .compact: 14
        }
    }

    var fixedWidth: CGFloat? {
        switch self {
        case .large: nil
        case .medium: 300
        case .compact(let width): width
        }
    }

    var priceFont: Font {
        switch self {
        case .large: .title2.bold()
        case .medium: .title3.bold()
        case .compact: .headline
        }
    }

    var statsFont: Font {
        switch self {
        case .large: .subheadline
        case .medium: .subheadline
        case .compact: .caption
        }
    }

    var addressFont: Font {
        switch self {
        case .large: .subheadline
        case .medium: .subheadline
        case .compact: .caption
        }
    }

    var tagFont: Font {
        switch self {
        case .large: .caption
        case .medium, .compact: .caption2
        }
    }

    var infoPadding: EdgeInsets {
        switch self {
        case .large: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        case .medium: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        case .compact: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
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
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: size.cornerRadius))
    }

    private var photoSection: some View {
        Color(.tertiarySystemBackground)
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
                        .padding(size.fixedWidth != nil ? 10 : 12)
                }
            }
    }

    private func badgeView(_ badge: HomeCardBadge) -> some View {
        Text(badge.text)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badge.color, in: .rect(cornerRadius: 6))
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
        case .hot: Color(white: 0.15)
        case .listedByRedfin: Color(red: 0.78, green: 0.13, blue: 0.13)
        case .compassComingSoon: .black
        case .daysAgo: Theme.redfinGreenColor
        }
    }
}

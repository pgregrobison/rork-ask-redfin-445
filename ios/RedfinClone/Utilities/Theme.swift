import SwiftUI

enum Theme {

    // MARK: - Legacy (backward-compatible)

    static let accent = Color.primary
    static let redfinGreenColor = Color(red: 27/255, green: 107/255, blue: 58/255)
    static let cardBackground = Color(.secondarySystemBackground)
    static let darkCardBackground = Color(white: 0.11)

    enum IconSize {
        static let medium: CGFloat = 17
        static let mediumTap: CGFloat = 44
        static let small: CGFloat = 15
        static let smallTap: CGFloat = 36
    }

    // MARK: - Brand Colors

    enum Colors {
        static let brandRed = Color(red: 0.78, green: 0.13, blue: 0.13)
        static let brandGreen = Color(red: 27/255, green: 107/255, blue: 58/255)
        static let invertedPrimary = Color(.systemBackground)

        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)

        static let fill = Color(.tertiarySystemFill)
        static let separator = Color(.separator)

        enum Chat {
            static let userBubbleLight = Color(.systemGray6)
            static let userBubbleDark = Color(red: 254/255, green: 254/255, blue: 254/255).opacity(0.12)
            static let inputCornerRadius: CGFloat = 24
        }

        static let stepIndicator = Color(white: 0.15)

        enum Badge {
            static let hot = Color(white: 0.15)
            static let listedByRedfin = Colors.brandRed
            static let compass = Color.black
            static let daysAgo = Colors.brandGreen
        }

        enum MapPin {
            static let selectedLight = Color(red: 0.87, green: 0.2, blue: 0.25)
            static let selectedDark = Color(red: 0.88, green: 0.23, blue: 0.23)
            static let seenLight = Color(red: 216/255, green: 216/255, blue: 220/255)
            static let seenDark = Color(red: 44/255, green: 44/255, blue: 46/255)
        }

        enum Chart {
            static let blue = Color(red: 0.2, green: 0.4, blue: 0.8)
            static let green = Color(red: 0.3, green: 0.7, blue: 0.4)
            static let amber = Color(red: 0.95, green: 0.7, blue: 0.2)
            static let purple = Color(red: 0.6, green: 0.4, blue: 0.8)
        }
    }

    // MARK: - Corner Radius

    enum Radius {
        static let xs: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = 9999
        static let chatBubble: CGFloat = 18
        static let widget: CGFloat = 16
        static let pill: CGFloat = 10
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Typography

    enum Typography {
        static let heroPrice: Font = .largeTitle.bold()
        static let sectionTitle: Font = .title2.bold()
        static let cardTitle: Font = .title3.bold()
        static let headline: Font = .headline
        static let body: Font = .body
        static let secondary: Font = .subheadline
        static let secondaryBold: Font = .subheadline.bold()
        static let caption: Font = .caption
        static let captionBold: Font = .caption.bold()
        static let micro: Font = .caption2
    }

    // MARK: - Shadows

    enum Shadow {
        static let subtleColor = Color.black.opacity(0.08)
        static let subtleRadius: CGFloat = 4
        static let subtleY: CGFloat = 2

        static let mediumColor = Color.black.opacity(0.12)
        static let mediumRadius: CGFloat = 10
        static let mediumY: CGFloat = 4

        static let elevatedColor = Color.black.opacity(0.20)
        static let elevatedRadius: CGFloat = 16
        static let elevatedY: CGFloat = 6

        static let overlayColor = Color.black.opacity(0.25)
        static let overlayRadius: CGFloat = 16
        static let overlayY: CGFloat = 4
    }

    // MARK: - Card Size Tokens

    enum CardSize {
        enum PhotoHeight {
            static let large: CGFloat = 240
            static let medium: CGFloat = 220
            static let compact: CGFloat = 180
        }

        enum FixedWidth {
            static let medium: CGFloat = 300
            static let compactDefault: CGFloat = 280
        }

        enum InfoPadding {
            static let large = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            static let medium = EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
            static let compact = EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        }
    }

    // MARK: - Divider Size

    enum DividerSize {
        static let standard: CGFloat = 32
    }

    // MARK: - Button Size Tokens

    enum ButtonSize {
        static let verticalPadding: CGFloat = 14
        static let compactVerticalPadding: CGFloat = 12
        static let pillHorizontalPadding: CGFloat = 18
        static let minHeight: CGFloat = 44
        static let iconSize: CGFloat = 16
        static let circleSize: CGFloat = 44
    }
}

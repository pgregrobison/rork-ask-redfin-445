import SwiftUI

enum Theme {
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
}

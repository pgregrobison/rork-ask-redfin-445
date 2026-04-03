import SwiftUI

extension View {
    func shadowSubtle() -> some View {
        self.shadow(
            color: Theme.Shadow.subtleColor,
            radius: Theme.Shadow.subtleRadius,
            y: Theme.Shadow.subtleY
        )
    }

    func shadowMedium() -> some View {
        self.shadow(
            color: Theme.Shadow.mediumColor,
            radius: Theme.Shadow.mediumRadius,
            y: Theme.Shadow.mediumY
        )
    }

    func shadowElevated() -> some View {
        self.shadow(
            color: Theme.Shadow.elevatedColor,
            radius: Theme.Shadow.elevatedRadius,
            y: Theme.Shadow.elevatedY
        )
    }
}

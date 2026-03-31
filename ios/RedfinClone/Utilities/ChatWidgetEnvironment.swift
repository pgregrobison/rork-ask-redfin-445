import SwiftUI

nonisolated struct ChatWidgetMessageIDKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var chatWidgetMessageID: String? {
        get { self[ChatWidgetMessageIDKey.self] }
        set { self[ChatWidgetMessageIDKey.self] = newValue }
    }
}

extension Notification.Name {
    static let chatWidgetFieldFocused = Notification.Name("chatWidgetFieldFocused")
}

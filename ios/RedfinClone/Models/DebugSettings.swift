import SwiftUI

nonisolated enum CardTransitionStyle: String, CaseIterable, Codable, Sendable {
    case nativePush = "Native Push"
    case fluidGrow = "Fluid Grow"
}

@Observable
class DebugSettings {
    var cardTransition: CardTransitionStyle {
        didSet { UserDefaults.standard.set(cardTransition.rawValue, forKey: "debug_cardTransition") }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: "debug_cardTransition") ?? ""
        self.cardTransition = CardTransitionStyle(rawValue: stored) ?? .nativePush
    }
}

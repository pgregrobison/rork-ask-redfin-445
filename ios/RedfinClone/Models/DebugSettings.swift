import SwiftUI

nonisolated enum CardTransitionStyle: String, CaseIterable, Codable, Sendable {
    case nativePush = "Native Push"
    case zoom = "Zoom"
}

nonisolated enum DetailPageStyle: String, CaseIterable, Codable, Sendable {
    case current = "Current"
    case james = "James"
}

nonisolated enum SearchBehavior: String, CaseIterable, Codable, Sendable {
    case `default` = "Default"
    case mapFocus = "Map Focus"
}

@Observable
class DebugSettings {
    var cardTransition: CardTransitionStyle {
        didSet { UserDefaults.standard.set(cardTransition.rawValue, forKey: "debug_cardTransition") }
    }

    var detailPageStyle: DetailPageStyle {
        didSet { UserDefaults.standard.set(detailPageStyle.rawValue, forKey: "debug_detailPageStyle") }
    }

    var searchBehavior: SearchBehavior {
        didSet { UserDefaults.standard.set(searchBehavior.rawValue, forKey: "debug_searchBehavior") }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: "debug_cardTransition") ?? ""
        self.cardTransition = CardTransitionStyle(rawValue: stored) ?? .nativePush
        let storedStyle = UserDefaults.standard.string(forKey: "debug_detailPageStyle") ?? ""
        self.detailPageStyle = DetailPageStyle(rawValue: storedStyle) ?? .current
        let storedBehavior = UserDefaults.standard.string(forKey: "debug_searchBehavior") ?? ""
        self.searchBehavior = SearchBehavior(rawValue: storedBehavior) ?? .default
    }
}

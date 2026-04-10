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

    var panDuration: Double {
        didSet { UserDefaults.standard.set(panDuration, forKey: "debug_panDuration") }
    }
    var panUseSpring: Bool {
        didSet { UserDefaults.standard.set(panUseSpring, forKey: "debug_panUseSpring") }
    }
    var panSpringResponse: Double {
        didSet { UserDefaults.standard.set(panSpringResponse, forKey: "debug_panSpringResponse") }
    }
    var panSpringDamping: Double {
        didSet { UserDefaults.standard.set(panSpringDamping, forKey: "debug_panSpringDamping") }
    }
    var overlaySpringResponse: Double {
        didSet { UserDefaults.standard.set(overlaySpringResponse, forKey: "debug_overlaySpringResponse") }
    }
    var overlaySpringDamping: Double {
        didSet { UserDefaults.standard.set(overlaySpringDamping, forKey: "debug_overlaySpringDamping") }
    }
    var dismissSpringResponse: Double {
        didSet { UserDefaults.standard.set(dismissSpringResponse, forKey: "debug_dismissSpringResponse") }
    }
    var dismissSpringDamping: Double {
        didSet { UserDefaults.standard.set(dismissSpringDamping, forKey: "debug_dismissSpringDamping") }
    }

    var panAnimation: Animation {
        if panUseSpring {
            return .spring(response: panSpringResponse, dampingFraction: panSpringDamping)
        } else {
            return .easeInOut(duration: panDuration)
        }
    }

    var overlayAnimation: Animation {
        .spring(response: overlaySpringResponse, dampingFraction: overlaySpringDamping)
    }

    var dismissAnimation: Animation {
        .spring(response: dismissSpringResponse, dampingFraction: dismissSpringDamping)
    }

    func resetAnimationDefaults() {
        panDuration = 0.35
        panUseSpring = false
        panSpringResponse = 0.35
        panSpringDamping = 0.8
        overlaySpringResponse = 0.35
        overlaySpringDamping = 0.8
        dismissSpringResponse = 0.35
        dismissSpringDamping = 0.8
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: "debug_cardTransition") ?? ""
        self.cardTransition = CardTransitionStyle(rawValue: stored) ?? .nativePush
        let storedStyle = UserDefaults.standard.string(forKey: "debug_detailPageStyle") ?? ""
        self.detailPageStyle = DetailPageStyle(rawValue: storedStyle) ?? .current
        let storedBehavior = UserDefaults.standard.string(forKey: "debug_searchBehavior") ?? ""
        self.searchBehavior = SearchBehavior(rawValue: storedBehavior) ?? .default

        let ud = UserDefaults.standard
        self.panDuration = ud.object(forKey: "debug_panDuration") as? Double ?? 0.35
        self.panUseSpring = ud.object(forKey: "debug_panUseSpring") as? Bool ?? false
        self.panSpringResponse = ud.object(forKey: "debug_panSpringResponse") as? Double ?? 0.35
        self.panSpringDamping = ud.object(forKey: "debug_panSpringDamping") as? Double ?? 0.8
        self.overlaySpringResponse = ud.object(forKey: "debug_overlaySpringResponse") as? Double ?? 0.35
        self.overlaySpringDamping = ud.object(forKey: "debug_overlaySpringDamping") as? Double ?? 0.8
        self.dismissSpringResponse = ud.object(forKey: "debug_dismissSpringResponse") as? Double ?? 0.35
        self.dismissSpringDamping = ud.object(forKey: "debug_dismissSpringDamping") as? Double ?? 0.8
    }
}

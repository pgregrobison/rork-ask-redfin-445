import SwiftUI

nonisolated enum SearchBehavior: String, CaseIterable, Codable, Sendable {
    case `default` = "Default"
    case mapFocus = "Map Focus"
}

nonisolated enum GlobalEntrypoint: String, CaseIterable, Codable, Sendable {
    case appNav = "App nav"
    case accessory = "Accessory"
}

@Observable
class DebugSettings {
    var searchBehavior: SearchBehavior {
        didSet { UserDefaults.standard.set(searchBehavior.rawValue, forKey: "debug_searchBehavior") }
    }

    var globalEntrypoint: GlobalEntrypoint {
        didSet { UserDefaults.standard.set(globalEntrypoint.rawValue, forKey: "debug_globalEntrypoint") }
    }

    static let panDuration: Double = 0.35
    static let overlaySpringResponse: Double = 0.35
    static let overlaySpringDamping: Double = 0.8
    static let dismissSpringResponse: Double = 0.35
    static let dismissSpringDamping: Double = 0.8

    var overlayAnimation: Animation {
        .spring(response: Self.overlaySpringResponse, dampingFraction: Self.overlaySpringDamping)
    }

    var dismissAnimation: Animation {
        .spring(response: Self.dismissSpringResponse, dampingFraction: Self.dismissSpringDamping)
    }

    init() {
        let storedBehavior = UserDefaults.standard.string(forKey: "debug_searchBehavior") ?? ""
        self.searchBehavior = SearchBehavior(rawValue: storedBehavior) ?? .mapFocus
        let storedEntry = UserDefaults.standard.string(forKey: "debug_globalEntrypoint") ?? ""
        self.globalEntrypoint = GlobalEntrypoint(rawValue: storedEntry) ?? .accessory
    }
}

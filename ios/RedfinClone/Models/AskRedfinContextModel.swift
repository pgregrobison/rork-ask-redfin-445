import SwiftUI

@Observable
final class AskRedfinContextModel {
    enum Context: Equatable {
        case `default`
        case map
        case mapCard
        case detailHero
        case detailPrice
        case detailFeatures
        case detailLifestyle
        case photoFocus
    }

    var context: Context = .default

    func suggestions(for ctx: Context) -> [String] {
        switch ctx {
        case .default:
            return [
                "Ask anything...",
                "Compare two homes",
                "Best areas for families?"
            ]
        case .map:
            return [
                "What's it like here?",
                "Schools in this area?",
                "Walkable to coffee?"
            ]
        case .mapCard:
            return [
                "Tell me about this home",
                "Why this price?",
                "What's the catch?",
                "Compare to nearby homes"
            ]
        case .detailHero:
            return [
                "Is this priced fairly?",
                "How long on market?"
            ]
        case .detailPrice:
            return [
                "Price vs. nearby homes?",
                "Estimate my payment",
                "Is this a good deal?"
            ]
        case .detailFeatures:
            return [
                "What stands out here?",
                "Any red flags?"
            ]
        case .detailLifestyle:
            return [
                "Schools nearby?",
                "What's the commute?"
            ]
        case .photoFocus:
            return [
                "What are these counters?",
                "What style is this?",
                "Cost to redo this room?"
            ]
        }
    }
}

extension EnvironmentValues {
    @Entry var askRedfinContext: AskRedfinContextModel = AskRedfinContextModel()
}

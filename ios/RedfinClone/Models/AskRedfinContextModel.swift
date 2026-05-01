import SwiftUI

@Observable
final class AskRedfinContextModel {
    enum Context: Equatable {
        case `default`
        case map
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
                "What's a good neighborhood for families?",
                "Help me compare two homes"
            ]
        case .map:
            return [
                "What's it like living here?",
                "How are the schools in this area?",
                "Walkable to coffee shops?"
            ]
        case .detailHero:
            return [
                "Is this priced fairly?",
                "How long has this been listed?"
            ]
        case .detailPrice:
            return [
                "How does this price compare to nearby homes?",
                "What would my monthly payment look like?"
            ]
        case .detailFeatures:
            return [
                "What stands out about this home?",
                "Any red flags in the details?"
            ]
        case .detailLifestyle:
            return [
                "How are the schools nearby?",
                "What's the commute like?"
            ]
        case .photoFocus:
            return [
                "What are these countertops made of?",
                "What style is this kitchen?",
                "Estimate the cost to redo this room"
            ]
        }
    }
}

extension EnvironmentValues {
    @Entry var askRedfinContext: AskRedfinContextModel = AskRedfinContextModel()
}

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
        case forYou
        case saved
        case myHome
        case myRedfin
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
                "3 beds with natural light",
                "Walkable, under $900k",
                "Quiet street with a yard",
                "Move-in ready near parks"
            ]
        case .forYou:
            return [
                "Show me homes I'd love",
                "What's new this week?",
                "More like the ones I saved"
            ]
        case .saved:
            return [
                "Compare my saved homes",
                "Which saved home is the best deal?",
                "Rank these by commute"
            ]
        case .myHome:
            return [
                "What's my home worth?",
                "How's my neighborhood trending?",
                "Should I refinance?"
            ]
        case .myRedfin:
            return [
                "Recap my recent searches",
                "Any updates on my tours?",
                "Help me pick an agent"
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
                "What style is this?",
                "What's this material?",
                "Cost to redo this room?"
            ]
        }
    }
}

extension EnvironmentValues {
    @Entry var askRedfinContext: AskRedfinContextModel = AskRedfinContextModel()
}

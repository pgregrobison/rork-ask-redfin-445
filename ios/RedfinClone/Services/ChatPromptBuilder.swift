import Foundation

@MainActor
enum ChatPromptBuilder {
    static let tools: [AIToolSchema] = [
        AIToolSchema(
            name: "search_homes",
            description: "Search NYC real estate listings. Call this whenever the user asks to find, see, or browse homes/apartments/condos. Use add_neighborhoods=true when the user says 'also', 'and', 'include', 'plus', or 'as well' to ADD to the existing neighborhood filter rather than replacing it.",
            parameters: [
                "type": "object",
                "properties": [
                    "min_beds": ["type": "integer", "description": "Minimum bedrooms. '3 bed' means min_beds=3 (interpreted as 3+)."],
                    "min_baths": ["type": "number", "description": "Minimum bathrooms (interpreted as N+)."],
                    "max_price": ["type": "integer", "description": "Maximum price in dollars (e.g. 1000000 for $1M)."],
                    "property_type": [
                        "type": "string",
                        "enum": ["Condo", "Townhouse", "Co-op", "Loft"],
                        "description": "Property type filter."
                    ],
                    "neighborhoods": [
                        "type": "array",
                        "items": ["type": "string"],
                        "description": "NYC neighborhood names (e.g. 'Upper West Side', 'Williamsburg', 'Tribeca')."
                    ],
                    "is_hot_home": ["type": "boolean", "description": "Limit to trending/hot listings."],
                    "add_neighborhoods": ["type": "boolean", "description": "When true, ADD the neighborhoods to the existing filter instead of replacing."]
                ]
            ]
        ),
        AIToolSchema(
            name: "schedule_tour",
            description: "Initiate a tour scheduling flow for a specific listing. Call this when the user wants to tour, visit, or see a home in person.",
            parameters: [
                "type": "object",
                "properties": [
                    "address": ["type": "string", "description": "Address mentioned by the user, if any."],
                    "listing_id": ["type": "string", "description": "Listing id from a prior search_homes result, if known."]
                ]
            ]
        ),
        AIToolSchema(
            name: "prequalify",
            description: "Start the mortgage prequalification flow. Call this when the user asks about affordability, mortgages, financing, prequalification, or 'can I afford this'.",
            parameters: [
                "type": "object",
                "properties": [
                    "listing_id": ["type": "string", "description": "Listing id the user is asking about, if known."]
                ]
            ]
        )
    ]

    static func systemPrompt(currentFilters: SearchFilters?) -> String {
        var lines: [String] = [
            "You are an NYC real-estate concierge inside a Redfin-style iOS app.",
            "You help users find homes for sale in NYC, schedule tours, and prequalify for mortgages.",
            "You have three tools: search_homes, schedule_tour, prequalify. Call a tool whenever the user's intent matches it.",
            "When the user describes what they want (beds, neighborhood, price, type), call search_homes immediately — do NOT ask follow-up questions first unless the request is truly ambiguous.",
            "Be concise (1–2 short sentences). Never list properties in prose — the UI renders cards from the search_homes result.",
            "Use add_neighborhoods=true when the user says 'also', 'and', 'plus', 'include', 'as well'.",
            "Always interpret '3 bed' / '3 bedroom' as min_beds=3 (3+).",
            "If no tool fits, write a brief friendly reply guiding the user to ask about homes, tours, or financing."
        ]

        if let f = currentFilters {
            var ctx: [String] = []
            if let v = f.minBeds { ctx.append("min_beds=\(v)") }
            if let v = f.minBaths { ctx.append("min_baths=\(v)") }
            if let v = f.maxPrice { ctx.append("max_price=\(v)") }
            if let v = f.propertyType { ctx.append("property_type=\(v)") }
            if let v = f.neighborhoods, !v.isEmpty { ctx.append("neighborhoods=\(v.joined(separator: ", "))") }
            if !ctx.isEmpty {
                lines.append("Current Find filters: \(ctx.joined(separator: "; ")).")
            }
        }

        return lines.joined(separator: "\n")
    }

    static func buildHistory(messages: [ChatMessage], limit: Int = 10) -> [AIMessage] {
        let recent = messages.suffix(limit)
        var out: [AIMessage] = []
        for m in recent {
            switch m.role {
            case .user:
                out.append(AIMessage(role: "user", content: m.content))
            case .assistant:
                if let calls = m.toolCalls, !calls.isEmpty {
                    let pending = calls.map { PendingToolCall(id: $0.id, name: $0.name, arguments: $0.arguments) }
                    out.append(AIMessage(role: "assistant", content: m.content.isEmpty ? nil : m.content, toolCalls: pending))
                    for c in calls {
                        if let result = c.result {
                            out.append(AIMessage(role: "tool", content: result, toolCallId: c.id))
                        }
                    }
                } else if !m.content.isEmpty {
                    out.append(AIMessage(role: "assistant", content: m.content))
                }
            case .system, .tool:
                continue
            }
        }
        return out
    }
}

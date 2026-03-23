import Foundation

nonisolated enum ChatRole: String, Codable, Sendable {
    case user
    case assistant
    case system
    case tool
}

nonisolated enum MessageFeedback: String, Codable, Sendable {
    case thumbsUp
    case thumbsDown
}

nonisolated struct TourRequest: Codable, Sendable {
    let listingId: String?
    let address: String?
}

nonisolated struct MortgageRequest: Codable, Sendable {
    let listingId: String?
}

nonisolated struct SearchFilters: Codable, Sendable {
    var minBeds: Int?
    var maxBeds: Int?
    var minBaths: Double?
    var maxBaths: Double?
    var minPrice: Int?
    var maxPrice: Int?
    var minSqft: Int?
    var maxSqft: Int?
    var propertyType: String?
    var isHotHome: Bool?
    var neighborhoods: [String]?
}

nonisolated struct ChatMessage: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let role: ChatRole
    var content: String
    let timestamp: Date
    var feedback: MessageFeedback?
    var searchResults: [String]?
    var tourRequest: TourRequest?
    var mortgageRequest: MortgageRequest?
    var isStreaming: Bool
    var isTourRoute: Bool
    var toolCalls: [ToolCallRecord]?

    init(
        id: String = UUID().uuidString,
        role: ChatRole,
        content: String,
        timestamp: Date = Date(),
        feedback: MessageFeedback? = nil,
        searchResults: [String]? = nil,
        tourRequest: TourRequest? = nil,
        mortgageRequest: MortgageRequest? = nil,
        isStreaming: Bool = false,
        isTourRoute: Bool = false,
        toolCalls: [ToolCallRecord]? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.feedback = feedback
        self.searchResults = searchResults
        self.tourRequest = tourRequest
        self.mortgageRequest = mortgageRequest
        self.isStreaming = isStreaming
        self.isTourRoute = isTourRoute
        self.toolCalls = toolCalls
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

nonisolated struct ToolCallRecord: Codable, Sendable, Hashable {
    let id: String
    let name: String
    let arguments: String
    var result: String?
}

nonisolated struct ChatThread: Identifiable, Codable, Sendable {
    let id: String
    var title: String
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date
    var isTourDay: Bool

    init(
        id: String = UUID().uuidString,
        title: String = "New Chat",
        messages: [ChatMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isTourDay: Bool = false
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isTourDay = isTourDay
    }
}

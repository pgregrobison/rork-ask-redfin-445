import Foundation
import SwiftUI

nonisolated enum ThinkingState: Equatable, Sendable {
    case none
    case thinking
    case searching
    case scheduling
    case mortgage
    
    var label: String {
        switch self {
        case .none: return ""
        case .thinking: return "Thinking"
        case .searching: return "Searching homes"
        case .scheduling: return "Setting up tour"
        case .mortgage: return "Preparing prequalification"
        }
    }
}

@Observable
@MainActor
class ChatViewModel {
    var threads: [ChatThread] = []
    var activeThreadId: String?
    var inputText: String = ""
    var thinkingState: ThinkingState = .none
    var showThreadSwitcher: Bool = false
    var lastSearchResults: [Listing] = []
    
    private let chatService = ChatService()
    private let storageKey = "chatThreads"
    private var streamTask: Task<Void, Never>?
    
    var activeThread: ChatThread? {
        guard let id = activeThreadId else { return nil }
        return threads.first { $0.id == id }
    }
    
    var activeMessages: [ChatMessage] {
        activeThread?.messages ?? []
    }
    
    var isTourDayThread: Bool {
        activeThread?.isTourDay ?? false
    }
    
    init() {
        loadThreads()
        if threads.isEmpty {
            createNewThread()
        } else {
            activeThreadId = threads.first?.id
        }
    }
    
    func createNewThread() {
        let thread = ChatThread()
        threads.insert(thread, at: 0)
        activeThreadId = thread.id
        saveThreads()
    }
    
    func switchToThread(_ threadId: String) {
        activeThreadId = threadId
        showThreadSwitcher = false
    }
    
    func deleteThread(_ threadId: String) {
        threads.removeAll { $0.id == threadId }
        if activeThreadId == threadId {
            activeThreadId = threads.first?.id
            if threads.isEmpty {
                createNewThread()
            }
        }
        saveThreads()
    }
    
    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        let lower = text.lowercased()
        if lower.contains("tour day") || lower.contains("start tour") {
            createTourDayThread()
            inputText = ""
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: text)
        appendMessage(userMessage)
        inputText = ""
        
        updateThreadTitle(from: text)
        
        streamTask?.cancel()
        streamTask = Task {
            await streamResponse()
        }
    }
    
    func createTourDayThread() {
        let thread = ChatThread(
            title: "Tour Day",
            isTourDay: true
        )
        threads.insert(thread, at: 0)
        activeThreadId = thread.id
        
        let welcomeMsg = ChatMessage(
            role: .assistant,
            content: "Welcome to Tour Day! I'll be your guide as you visit homes today. You have 3 stops planned. Let me show you the route."
        )
        appendMessage(welcomeMsg)
        
        let routeMsg = ChatMessage(
            role: .assistant,
            content: "",
            isTourRoute: true
        )
        appendMessage(routeMsg)
        
        let tipMsg = ChatMessage(
            role: .assistant,
            content: "Tap the microphone button to use voice mode while touring. I'll keep my responses brief so you can focus on the homes!"
        )
        appendMessage(tipMsg)
        
        saveThreads()
    }
    
    func setFeedback(_ feedback: MessageFeedback, for messageId: String) {
        guard let threadIndex = threads.firstIndex(where: { $0.id == activeThreadId }),
              let msgIndex = threads[threadIndex].messages.firstIndex(where: { $0.id == messageId }) else { return }
        
        if threads[threadIndex].messages[msgIndex].feedback == feedback {
            threads[threadIndex].messages[msgIndex].feedback = nil
        } else {
            threads[threadIndex].messages[msgIndex].feedback = feedback
        }
        saveThreads()
    }
    
    func stopStreaming() {
        streamTask?.cancel()
        thinkingState = .none
        
        guard let threadIndex = threads.firstIndex(where: { $0.id == activeThreadId }) else { return }
        if let lastIndex = threads[threadIndex].messages.indices.last,
           threads[threadIndex].messages[lastIndex].isStreaming {
            threads[threadIndex].messages[lastIndex].isStreaming = false
        }
        saveThreads()
    }
    
    private func streamResponse() async {
        thinkingState = .thinking
        
        let messages = activeMessages
        
        let assistantMessage = ChatMessage(
            role: .assistant,
            content: "",
            isStreaming: true
        )
        appendMessage(assistantMessage)
        let assistantMsgId = assistantMessage.id
        
        var accumulatedText = ""
        var pendingToolCalls: [(id: String, name: String, arguments: String)] = []
        
        for await delta in chatService.sendMessage(messages: messages) {
            if Task.isCancelled { break }
            
            if let text = delta.text {
                accumulatedText += text
                thinkingState = .none
                updateMessageContent(assistantMsgId, content: accumulatedText)
            }
            
            if delta.finishReason == "tool_calls",
               let toolId = delta.toolCallId,
               let toolName = delta.toolCallName,
               let toolArgs = delta.toolCallArguments {
                pendingToolCalls.append((id: toolId, name: toolName, arguments: toolArgs))
            }
            
            if delta.finishReason == "error" {
                thinkingState = .none
                finalizeMessage(assistantMsgId)
                return
            }
        }
        
        if !pendingToolCalls.isEmpty {
            for toolCall in pendingToolCalls {
                await handleToolCall(
                    messageId: assistantMsgId,
                    toolId: toolCall.id,
                    toolName: toolCall.name,
                    arguments: toolCall.arguments
                )
            }
        }
        
        thinkingState = .none
        finalizeMessage(assistantMsgId)
        saveThreads()
    }
    
    private func handleToolCall(messageId: String, toolId: String, toolName: String, arguments: String) async {
        switch toolName {
        case "searchListings":
            thinkingState = .searching
            
            let filters = parseSearchFilters(arguments)
            let results = chatService.searchListings(filters: filters)
            lastSearchResults = results
            
            let resultIds = results.map { $0.id }
            
            guard let threadIndex = threads.firstIndex(where: { $0.id == activeThreadId }),
                  let msgIndex = threads[threadIndex].messages.firstIndex(where: { $0.id == messageId }) else { return }
            
            threads[threadIndex].messages[msgIndex].searchResults = resultIds
            
            let toolCall = ToolCall(id: toolId, name: toolName, arguments: arguments, status: .completed, result: "\(results.count) listings found")
            if threads[threadIndex].messages[msgIndex].toolCalls == nil {
                threads[threadIndex].messages[msgIndex].toolCalls = []
            }
            threads[threadIndex].messages[msgIndex].toolCalls?.append(toolCall)
            
            if threads[threadIndex].messages[msgIndex].content.isEmpty {
                let summary = buildSearchSummary(results: results, filters: filters)
                threads[threadIndex].messages[msgIndex].content = summary
            }
            
            thinkingState = .none
            
        case "scheduleTour":
            thinkingState = .scheduling
            
            let tourRequest = parseTourRequest(arguments)
            
            guard let threadIndex = threads.firstIndex(where: { $0.id == activeThreadId }),
                  let msgIndex = threads[threadIndex].messages.firstIndex(where: { $0.id == messageId }) else { return }
            
            threads[threadIndex].messages[msgIndex].tourRequest = tourRequest
            
            if threads[threadIndex].messages[msgIndex].content.isEmpty {
                let addr = tourRequest.address ?? "this property"
                threads[threadIndex].messages[msgIndex].content = "I'd love to help you schedule a tour for \(addr)! Use the form below to pick your preferred date and time."
            }
            
            thinkingState = .none
            
        case "getMortgagePrequal":
            thinkingState = .mortgage
            
            let mortgageReq = parseMortgageRequest(arguments)
            
            guard let threadIndex = threads.firstIndex(where: { $0.id == activeThreadId }),
                  let msgIndex = threads[threadIndex].messages.firstIndex(where: { $0.id == messageId }) else { return }
            
            threads[threadIndex].messages[msgIndex].mortgageRequest = mortgageReq
            
            if threads[threadIndex].messages[msgIndex].content.isEmpty {
                threads[threadIndex].messages[msgIndex].content = "Let's get you prequalified! Fill out the form below to see what you can afford."
            }
            
            thinkingState = .none
            
        default:
            break
        }
    }
    
    private func parseSearchFilters(_ json: String) -> SearchFilters {
        guard let data = json.data(using: .utf8) else { return SearchFilters() }
        return (try? JSONDecoder().decode(SearchFilters.self, from: data)) ?? SearchFilters()
    }
    
    private func parseTourRequest(_ json: String) -> TourRequest {
        guard let data = json.data(using: .utf8) else { return TourRequest(listingId: nil, address: nil) }
        return (try? JSONDecoder().decode(TourRequest.self, from: data)) ?? TourRequest(listingId: nil, address: nil)
    }
    
    private func parseMortgageRequest(_ json: String) -> MortgageRequest {
        guard let data = json.data(using: .utf8) else { return MortgageRequest(listingId: nil) }
        return (try? JSONDecoder().decode(MortgageRequest.self, from: data)) ?? MortgageRequest(listingId: nil)
    }
    
    private func buildSearchSummary(results: [Listing], filters: SearchFilters) -> String {
        if results.isEmpty {
            return "I couldn't find any listings matching your criteria. Try adjusting your filters — maybe a different price range or neighborhood?"
        }
        
        var parts: [String] = ["I found \(results.count) home\(results.count == 1 ? "" : "s")"]
        
        if let pt = filters.propertyType {
            parts[0] += " (\(pt.lowercased())\(results.count == 1 ? "" : "s"))"
        }
        
        var filterDesc: [String] = []
        if let minBeds = filters.minBeds {
            filterDesc.append("\(minBeds)+ bedrooms")
        }
        if let maxPrice = filters.maxPrice {
            let formatted = maxPrice >= 1_000_000 ? "$\(maxPrice / 1_000_000)M" : "$\(maxPrice / 1000)K"
            filterDesc.append("under \(formatted)")
        }
        if let neighborhoods = filters.neighborhoods, !neighborhoods.isEmpty {
            filterDesc.append("in \(neighborhoods.joined(separator: ", "))")
        }
        
        if !filterDesc.isEmpty {
            parts.append("with \(filterDesc.joined(separator: ", "))")
        }
        
        return parts.joined(separator: " ") + ". Here's what I found:"
    }
    
    private func appendMessage(_ message: ChatMessage) {
        guard let threadIndex = threads.firstIndex(where: { $0.id == activeThreadId }) else { return }
        threads[threadIndex].messages.append(message)
        threads[threadIndex].updatedAt = Date()
    }
    
    private func updateMessageContent(_ messageId: String, content: String) {
        guard let threadIndex = threads.firstIndex(where: { $0.id == activeThreadId }),
              let msgIndex = threads[threadIndex].messages.firstIndex(where: { $0.id == messageId }) else { return }
        threads[threadIndex].messages[msgIndex].content = content
    }
    
    private func finalizeMessage(_ messageId: String) {
        guard let threadIndex = threads.firstIndex(where: { $0.id == activeThreadId }),
              let msgIndex = threads[threadIndex].messages.firstIndex(where: { $0.id == messageId }) else { return }
        threads[threadIndex].messages[msgIndex].isStreaming = false
    }
    
    private func updateThreadTitle(from text: String) {
        guard let threadIndex = threads.firstIndex(where: { $0.id == activeThreadId }) else { return }
        if threads[threadIndex].title == "New Chat" {
            let title = String(text.prefix(40))
            threads[threadIndex].title = title.count < text.count ? title + "…" : title
        }
    }
    
    private func saveThreads() {
        guard let data = try? JSONEncoder().encode(threads) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    private func loadThreads() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ChatThread].self, from: data) else { return }
        threads = decoded
    }
}

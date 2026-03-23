import Foundation
import SwiftUI

nonisolated enum ThinkingState: Equatable, Sendable {
    case none
    case thinking
    case searching

    var label: String {
        switch self {
        case .none: return ""
        case .thinking: return "Thinking"
        case .searching: return "Searching homes"
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
    private let storageKey = "chatThreads_v2"
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
        UserDefaults.standard.removeObject(forKey: "chatThreads")
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
            if threads.isEmpty { createNewThread() }
        }
        saveThreads()
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: text)
        appendMessage(userMessage)
        inputText = ""
        updateThreadTitle(from: text)

        streamTask?.cancel()
        streamTask = Task { await streamResponse() }
    }

    func setFeedback(_ feedback: MessageFeedback, for messageId: String) {
        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }),
              let mi = threads[ti].messages.firstIndex(where: { $0.id == messageId }) else { return }

        if threads[ti].messages[mi].feedback == feedback {
            threads[ti].messages[mi].feedback = nil
        } else {
            threads[ti].messages[mi].feedback = feedback
        }
        saveThreads()
    }

    func stopStreaming() {
        streamTask?.cancel()
        thinkingState = .none

        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }) else { return }
        if let last = threads[ti].messages.indices.last,
           threads[ti].messages[last].isStreaming {
            threads[ti].messages[last].isStreaming = false
        }
        saveThreads()
    }

    private func streamResponse() async {
        thinkingState = .thinking

        let assistantMsg = ChatMessage(role: .assistant, content: "", isStreaming: true)
        appendMessage(assistantMsg)
        let msgId = assistantMsg.id

        var text = ""
        var pendingToolCalls: [(id: String, name: String, args: String)] = []
        var currentToolId: String?

        for await event in chatService.sendMessage(messages: activeMessages) {
            if Task.isCancelled { break }

            switch event.kind {
            case .textDelta(let delta):
                text += delta
                thinkingState = .none
                updateMessageContent(msgId, content: text)

            case .toolCallStart(let toolCallId, _):
                currentToolId = toolCallId

            case .toolCallDelta(_, _):
                break

            case .toolCallReady(let toolCallId, let toolName, let input):
                pendingToolCalls.append((id: toolCallId, name: toolName, args: input))
                currentToolId = nil

            case .done:
                break

            case .error(let errorMsg):
                if text.isEmpty {
                    text = "I'm having trouble connecting right now. Please try again. (\(errorMsg))"
                    updateMessageContent(msgId, content: text)
                }
                thinkingState = .none
                finalizeMessage(msgId)
                saveThreads()
                return
            }
        }

        if !pendingToolCalls.isEmpty {
            for tc in pendingToolCalls {
                await handleToolCall(messageId: msgId, toolId: tc.id, toolName: tc.name, arguments: tc.args, currentText: text)
            }
        }

        thinkingState = .none
        finalizeMessage(msgId)
        saveThreads()
    }

    private func handleToolCall(messageId: String, toolId: String, toolName: String, arguments: String, currentText: String) async {
        guard toolName == "searchListings" else { return }

        thinkingState = .searching

        let filters = parseSearchFilters(arguments)
        let results = chatService.searchListings(filters: filters)
        lastSearchResults = results

        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }),
              let mi = threads[ti].messages.firstIndex(where: { $0.id == messageId }) else { return }

        threads[ti].messages[mi].searchResults = results.map { $0.id }

        let toolRecord = ToolCallRecord(id: toolId, name: toolName, arguments: arguments, result: "\(results.count) listings found")
        if threads[ti].messages[mi].toolCalls == nil {
            threads[ti].messages[mi].toolCalls = []
        }
        threads[ti].messages[mi].toolCalls?.append(toolRecord)

        if threads[ti].messages[mi].content.isEmpty {
            threads[ti].messages[mi].content = buildSearchSummary(results: results, filters: filters)
        }

        thinkingState = .none
    }

    private func parseSearchFilters(_ json: String) -> SearchFilters {
        guard let data = json.data(using: .utf8) else { return SearchFilters() }
        return (try? JSONDecoder().decode(SearchFilters.self, from: data)) ?? SearchFilters()
    }

    private func buildSearchSummary(results: [Listing], filters: SearchFilters) -> String {
        if results.isEmpty {
            return "I couldn't find any listings matching those criteria. Try adjusting your filters."
        }

        var desc = "I found \(results.count) home\(results.count == 1 ? "" : "s")"

        var parts: [String] = []
        if let minBeds = filters.minBeds { parts.append("\(minBeds)+ bedrooms") }
        if let maxPrice = filters.maxPrice {
            let fmt = maxPrice >= 1_000_000 ? "$\(maxPrice / 1_000_000)M" : "$\(maxPrice / 1000)K"
            parts.append("under \(fmt)")
        }
        if let neighborhoods = filters.neighborhoods, !neighborhoods.isEmpty {
            parts.append("in \(neighborhoods.joined(separator: ", "))")
        }

        if !parts.isEmpty { desc += " with \(parts.joined(separator: ", "))" }
        return desc + ". Here's what I found:"
    }

    private func appendMessage(_ message: ChatMessage) {
        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }) else { return }
        threads[ti].messages.append(message)
        threads[ti].updatedAt = Date()
    }

    private func updateMessageContent(_ messageId: String, content: String) {
        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }),
              let mi = threads[ti].messages.firstIndex(where: { $0.id == messageId }) else { return }
        threads[ti].messages[mi].content = content
    }

    private func finalizeMessage(_ messageId: String) {
        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }),
              let mi = threads[ti].messages.firstIndex(where: { $0.id == messageId }) else { return }
        threads[ti].messages[mi].isStreaming = false
    }

    private func updateThreadTitle(from text: String) {
        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }) else { return }
        if threads[ti].title == "New Chat" {
            let title = String(text.prefix(40))
            threads[ti].title = title.count < text.count ? title + "…" : title
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

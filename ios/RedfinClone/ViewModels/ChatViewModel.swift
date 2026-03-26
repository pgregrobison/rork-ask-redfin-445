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
        let welcomeMessage = ChatMessage(
            role: .assistant,
            content: "Hey there! I see you're looking near Garner and Raleigh. I can help you find the perfect home \u{2014} just let me know what you're looking for, and I'll take care of the rest."
        )
        let thread = ChatThread(messages: [welcomeMessage])
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
        streamTask = Task { await generateResponse(for: text) }
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

    private func generateResponse(for input: String) async {
        thinkingState = .thinking

        let response = chatService.matchResponse(for: input)

        try? await Task.sleep(for: .milliseconds(Int.random(in: 400...800)))
        if Task.isCancelled { return }

        let assistantMsg = ChatMessage(role: .assistant, content: "", isStreaming: true)
        appendMessage(assistantMsg)
        let msgId = assistantMsg.id

        let responseText: String
        var searchFilters: SearchFilters?

        switch response {
        case .listings(let text, let filters):
            thinkingState = .searching
            try? await Task.sleep(for: .milliseconds(Int.random(in: 300...600)))
            if Task.isCancelled { return }
            thinkingState = .none
            responseText = text
            searchFilters = filters

        case .tour(let text):
            thinkingState = .none
            responseText = text

        case .fallback(let text):
            thinkingState = .none
            responseText = text
        }

        await streamText(responseText, toMessageId: msgId)
        if Task.isCancelled { return }

        if let filters = searchFilters {
            let results = chatService.searchListings(filters: filters)
            lastSearchResults = results

            guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }),
                  let mi = threads[ti].messages.firstIndex(where: { $0.id == msgId }) else { return }

            threads[ti].messages[mi].searchResults = results.map { $0.id }
        }

        finalizeMessage(msgId)
        saveThreads()
    }

    private func streamText(_ text: String, toMessageId msgId: String) async {
        var streamed = ""
        let chars = Array(text)
        var i = 0

        while i < chars.count {
            if Task.isCancelled { return }

            let chunkSize = min(Int.random(in: 1...3), chars.count - i)
            for j in 0..<chunkSize {
                streamed.append(chars[i + j])
            }
            i += chunkSize

            updateMessageContent(msgId, content: streamed)

            let delay = chars[i - 1] == "." || chars[i - 1] == "!" || chars[i - 1] == "?" ? 60 : Int.random(in: 15...35)
            try? await Task.sleep(for: .milliseconds(delay))
        }

        updateMessageContent(msgId, content: text)
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

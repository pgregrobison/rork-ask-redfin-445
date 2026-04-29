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
    var scrollPositions: [String: String] = [:]
    var carouselScrollPositions: [String: String] = [:]
    var bottomSpacerHeights: [String: CGFloat] = [:]
    var isVoiceModeActive: Bool = false
    var isVoiceMuted: Bool = false
    var voiceTranscriptMessageId: String?
    var voiceScrollToTopId: String?
    var searchResultsJustArrived: [Listing]?
    var searchFiltersJustArrived: SearchFilters?
    var searchAddNeighborhoodsJustArrived: Bool = false
    var debugSettings: DebugSettings?
    var currentFindFiltersProvider: (() -> SearchFilters)?

    private let chatService = ChatService()
    private let aiService = AIService()
    private let toolExecutor: ToolExecutor
    private let storageKey = "chatThreads_v2"
    private var streamTask: Task<Void, Never>?
    private var voiceSimTask: Task<Void, Never>?

    private let voiceSimPhrases = [
        "I'm looking for a 3 bedroom home near downtown Raleigh with a big backyard"
    ]

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
        self.toolExecutor = ToolExecutor(chatService: chatService)
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

    func activateVoiceMode() {
        isVoiceModeActive = true
        isVoiceMuted = false
        voiceSimTask?.cancel()
        voiceSimTask = Task { await simulateVoiceInput() }
    }

    func deactivateVoiceMode() {
        isVoiceModeActive = false
        isVoiceMuted = false
        voiceSimTask?.cancel()
        voiceSimTask = nil

        if let msgId = voiceTranscriptMessageId {
            finalizeMessage(msgId)
            voiceTranscriptMessageId = nil
        }
    }

    func toggleVoiceMute() {
        isVoiceMuted.toggle()
    }

    private func simulateVoiceInput() async {
        while isVoiceMuted {
            if Task.isCancelled { return }
            try? await Task.sleep(for: .milliseconds(100))
        }

        try? await Task.sleep(for: .seconds(1.5))
        if Task.isCancelled { return }

        while isVoiceMuted {
            if Task.isCancelled { return }
            try? await Task.sleep(for: .milliseconds(100))
        }

        let phrase = voiceSimPhrases[0]
        let words = phrase.split(separator: " ").map(String.init)

        let userMsg = ChatMessage(role: .user, content: "", isStreaming: true)
        appendMessage(userMsg)
        voiceTranscriptMessageId = userMsg.id
        updateThreadTitle(from: phrase)

        if let threadId = activeThreadId {
            bottomSpacerHeights[threadId] = UIScreen.main.bounds.height
        }
        voiceScrollToTopId = userMsg.id

        var accumulated = ""
        for (i, word) in words.enumerated() {
            if Task.isCancelled { return }
            while isVoiceMuted {
                if Task.isCancelled { return }
                try? await Task.sleep(for: .milliseconds(100))
            }
            accumulated += (i > 0 ? " " : "") + word
            updateMessageContent(userMsg.id, content: accumulated)
            try? await Task.sleep(for: .milliseconds(Int.random(in: 180...350)))
        }

        if Task.isCancelled { return }
        finalizeMessage(userMsg.id)
        voiceTranscriptMessageId = nil

        try? await Task.sleep(for: .milliseconds(600))
        if Task.isCancelled { return }

        streamTask?.cancel()
        streamTask = Task { await generateResponse(for: phrase) }
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
        let thinkingStart = ContinuousClock.now
        let realistic = debugSettings?.realisticModeEnabled == true

        let history = activeMessages.dropLast()
        let currentFilters = currentFindFiltersProvider?() ?? SearchFilters()
        var aiMessages: [AIMessage] = [
            AIMessage(role: "system", content: ChatPromptBuilder.systemPrompt(currentFilters: currentFilters))
        ]
        aiMessages.append(contentsOf: ChatPromptBuilder.buildHistory(messages: Array(history)))
        aiMessages.append(AIMessage(role: "user", content: input))

        let assistantMsg = ChatMessage(role: .assistant, content: "", isStreaming: true)
        appendMessage(assistantMsg)
        let msgId = assistantMsg.id

        var completedToolCalls: [ToolCallRecord] = []
        var finalSearchFilters: SearchFilters?
        var finalSearchResults: [Listing]?
        var finalAddNbhd = false
        var finalTour: TourRequest?
        var finalMortgage: MortgageRequest?
        var hasStartedTextOutput = false
        let maxIterations = 4

        for _ in 0..<maxIterations {
            if Task.isCancelled { break }

            var pendingCalls: [Int: (id: String, name: String, args: String)] = [:]
            var finishReason: String?
            var streamedText = ""

            do {
                for try await event in aiService.stream(messages: aiMessages, tools: ChatPromptBuilder.tools) {
                    if Task.isCancelled { break }
                    switch event {
                    case .textDelta(let chunk):
                        if !hasStartedTextOutput {
                            hasStartedTextOutput = true
                            await enforceMinimumThinking(start: thinkingStart, isSearching: false, realistic: realistic)
                            if Task.isCancelled { break }
                            thinkingState = .none
                        }
                        streamedText += chunk
                        let existing = currentMessageContent(msgId) ?? ""
                        updateMessageContent(msgId, content: existing + chunk)
                    case .toolCallStart(let index, let id, let name):
                        pendingCalls[index] = (id: id, name: name, args: "")
                        if name == "search_homes" {
                            thinkingState = .searching
                        }
                    case .toolCallArgsDelta(let index, let json):
                        if var existing = pendingCalls[index] {
                            existing.args += json
                            pendingCalls[index] = existing
                        }
                    case .finish(let reason):
                        finishReason = reason
                    }
                }
            } catch {
                if Task.isCancelled { return }
                let aiErr = (error as? AIError)?.userFacing ?? "Something went wrong, please try again."
                let existing = currentMessageContent(msgId) ?? ""
                let body = existing.isEmpty ? aiErr : existing
                updateMessageContent(msgId, content: body)
                thinkingState = .none
                finalizeMessage(msgId)
                saveThreads()
                return
            }

            if Task.isCancelled { return }

            guard finishReason == "tool_calls", !pendingCalls.isEmpty else {
                break
            }

            let orderedCalls = pendingCalls.keys.sorted().compactMap { pendingCalls[$0] }
            let assistantToolCalls = orderedCalls.map {
                PendingToolCall(id: $0.id, name: $0.name, arguments: $0.args)
            }
            aiMessages.append(AIMessage(
                role: "assistant",
                content: streamedText.isEmpty ? nil : streamedText,
                toolCalls: assistantToolCalls
            ))

            var hasSearch = false
            for call in orderedCalls {
                if call.name == "search_homes" { hasSearch = true }
            }
            if hasSearch && realistic {
                let elapsed = ContinuousClock.now - thinkingStart
                if elapsed < .seconds(8) {
                    try? await Task.sleep(for: .seconds(8) - elapsed)
                }
                if Task.isCancelled { return }
            }

            for call in orderedCalls {
                let result = toolExecutor.execute(
                    name: call.name,
                    arguments: call.args,
                    currentFindFilters: currentFilters
                )
                completedToolCalls.append(ToolCallRecord(
                    id: call.id,
                    name: call.name,
                    arguments: call.args,
                    result: result.resultJSON
                ))
                aiMessages.append(AIMessage(role: "tool", content: result.resultJSON, toolCallId: call.id))

                if call.name == "search_homes" {
                    finalSearchFilters = result.searchFilters
                    finalSearchResults = result.searchResults
                    finalAddNbhd = result.addNeighborhoods
                }
                if let tour = result.tourRequest { finalTour = tour }
                if let mort = result.mortgageRequest { finalMortgage = mort }
            }
        }

        if !hasStartedTextOutput {
            await enforceMinimumThinking(
                start: thinkingStart,
                isSearching: finalSearchResults != nil,
                realistic: realistic
            )
        }
        if Task.isCancelled { return }
        thinkingState = .none

        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }),
              let mi = threads[ti].messages.firstIndex(where: { $0.id == msgId }) else { return }

        if !completedToolCalls.isEmpty {
            threads[ti].messages[mi].toolCalls = completedToolCalls
        }

        if let filters = finalSearchFilters, let results = finalSearchResults {
            lastSearchResults = results
            threads[ti].messages[mi].searchResults = results.map { $0.id }
            threads[ti].messages[mi].searchFilters = filters
            searchResultsJustArrived = results
            searchFiltersJustArrived = filters
            searchAddNeighborhoodsJustArrived = finalAddNbhd
        }
        if let tour = finalTour {
            threads[ti].messages[mi].tourRequest = tour
        }
        if let mort = finalMortgage {
            threads[ti].messages[mi].mortgageRequest = mort
        }

        if threads[ti].messages[mi].content.isEmpty {
            let fallback: String
            if finalSearchResults != nil {
                fallback = "Here are some homes that match."
            } else if finalTour != nil {
                fallback = "Let's get you scheduled for a tour."
            } else if finalMortgage != nil {
                fallback = "Let's get you prequalified."
            } else {
                fallback = ""
            }
            if !fallback.isEmpty {
                threads[ti].messages[mi].content = fallback
            }
        }

        finalizeMessage(msgId)
        saveThreads()
    }

    private func enforceMinimumThinking(start: ContinuousClock.Instant, isSearching: Bool, realistic: Bool) async {
        let elapsed = ContinuousClock.now - start
        let minimum: Duration = (realistic && isSearching) ? .seconds(8) : .seconds(2)
        if elapsed < minimum {
            try? await Task.sleep(for: minimum - elapsed)
        }
    }

    private func currentMessageContent(_ messageId: String) -> String? {
        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }),
              let mi = threads[ti].messages.firstIndex(where: { $0.id == messageId }) else { return nil }
        return threads[ti].messages[mi].content
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

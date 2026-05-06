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
    var tourDayHint: String?
    var tourDayCurrentStopIndex: Int = 0
    var searchResultsJustArrived: [Listing]?
    var searchFiltersJustArrived: SearchFilters?
    var searchAddNeighborhoodsJustArrived: Bool = false
    var debugSettings: DebugSettings?
    var currentFindFiltersProvider: (() -> SearchFilters)?
    var focusInputOnAppear: Bool = false

    private let chatService = ChatService()
    private let storageKey = "chatThreads_v2"
    private var streamTask: Task<Void, Never>?
    private var voiceSimTask: Task<Void, Never>?
    private var tourDayTask: Task<Void, Never>?

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

        if text.lowercased().contains("tour day") {
            requestTourDayNotification()
            return
        }

        streamTask?.cancel()
        streamTask = Task { await generateResponse(for: text) }
    }

    var requestTourDayNotificationHandler: (() -> Void)?

    func requestTourDayNotification() {
        requestTourDayNotificationHandler?()
    }

    func startTourDay() {
        tourDayTask?.cancel()
        streamTask?.cancel()
        thinkingState = .none

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let title = "Tour Day · \(formatter.string(from: Date()))"
        let thread = ChatThread(title: title, messages: [], isTourDay: true)
        threads.insert(thread, at: 0)
        activeThreadId = thread.id
        tourDayCurrentStopIndex = 0
        saveThreads()

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        tourDayTask = Task { await runTourDayScript() }
    }

    private func runTourDayScript() async {
        try? await Task.sleep(for: .milliseconds(400))
        if Task.isCancelled { return }

        await streamAssistantMessage("Welcome to tour day! I've created a new thread for all things tours. Here's your day at a glance.")
        if Task.isCancelled { return }

        try? await Task.sleep(for: .milliseconds(700))
        if Task.isCancelled { return }

        let routeMsg = ChatMessage(
            role: .assistant,
            content: "I mapped out the most efficient route for your 4 tours today.",
            isStreaming: false,
            tourDayRoute: TourDayData.demoRoute
        )
        appendMessage(routeMsg)
        saveThreads()

        try? await Task.sleep(for: .seconds(2))
        if Task.isCancelled { return }

        for stop in TourDayData.demoRoute.stops {
            if Task.isCancelled { return }
            tourDayCurrentStopIndex = stop.id
            try? await Task.sleep(for: .seconds(2))
            if Task.isCancelled { return }

            let intro: String
            if stop.id == 1 {
                intro = "First stop coming up at \(stop.time). Heading to the Tribeca home now."
            } else {
                intro = stopTransitionPrompt(for: stop.id)
            }
            await streamAssistantMessage(intro, currentStopId: nil)
            if Task.isCancelled { return }

            let card = ChatMessage(
                role: .assistant,
                content: "",
                tourDayCurrentStopId: stop.listingId
            )
            appendMessage(card)
            saveThreads()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            if stop.id > 1 {
                tourDayHint = "Tap the waveform to reply by voice"
                try? await Task.sleep(for: .seconds(5))
                tourDayHint = nil
                if Task.isCancelled { return }
            } else {
                try? await Task.sleep(for: .seconds(4))
                if Task.isCancelled { return }
            }
        }

        if Task.isCancelled { return }
        tourDayCurrentStopIndex = 0
        try? await Task.sleep(for: .seconds(1))

        let summary = """
        That's a wrap on tour day! Here's a recap of what you loved and didn't — I've passed this along to your agent.

        • 100 Barclay St — Loved the natural light; kitchen felt cramped.
        • 88 Greenwich St — Beautiful finishes, but the second bedroom was tight.
        • 55 Hudson Yards — Top pick. The view sold you.
        • 142 W 82nd St — Great space, unsure about the location.
        """
        let summaryMsg = ChatMessage(
            role: .assistant,
            content: summary,
            isTourDaySummary: true
        )
        appendMessage(summaryMsg)
        saveThreads()
    }

    private func stopTransitionPrompt(for stopId: Int) -> String {
        switch stopId {
        case 2: return "On your way to the 2nd tour — let me know what you thought of the first home."
        case 3: return "Heading to tour #3. How did the second one feel?"
        case 4: return "Last stop ahead. What did you think of #3?"
        default: return "Next stop coming up."
        }
    }

    private func streamAssistantMessage(_ text: String, currentStopId: String? = nil) async {
        let msg = ChatMessage(role: .assistant, content: "", isStreaming: true, tourDayCurrentStopId: currentStopId)
        appendMessage(msg)
        await streamText(text, toMessageId: msg.id)
        finalizeMessage(msg.id)
        saveThreads()
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

    private func tourDayVoicePhrase() -> String? {
        guard isTourDayThread, tourDayCurrentStopIndex > 0 else { return nil }
        return TourDayData.voicePhrasesByStop[tourDayCurrentStopIndex]
    }

    private func tourDayAssistantAck() -> String? {
        guard isTourDayThread, tourDayCurrentStopIndex > 0 else { return nil }
        return TourDayData.assistantAcksByStop[tourDayCurrentStopIndex]
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

        let phrase = tourDayVoicePhrase() ?? voiceSimPhrases[0]
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

        if let ack = tourDayAssistantAck() {
            isVoiceModeActive = false
            isVoiceMuted = false
            tourDayHint = nil
            await streamAssistantMessage(ack)
            return
        }

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

        let response = chatService.matchResponse(for: input)

        try? await Task.sleep(for: .milliseconds(Int.random(in: 500...900)))
        if Task.isCancelled { return }

        let responseText: String
        var searchFilters: SearchFilters?
        var tourReq: TourRequest?
        var mortgageReq: MortgageRequest?

        var addNbhd = false
        switch response {
        case .listings(let text, let filters, let add):
            thinkingState = .searching
            try? await Task.sleep(for: .milliseconds(Int.random(in: 300...600)))
            if Task.isCancelled { return }
            responseText = text
            searchFilters = filters
            addNbhd = add

        case .tour(let text, let request):
            responseText = text
            tourReq = request

        case .mortgage(let text, let request):
            responseText = text
            mortgageReq = request

        case .fallback(let text):
            responseText = text
        }

        let elapsed = ContinuousClock.now - thinkingStart
        let minimumThinking: Duration = .seconds(2)
        if elapsed < minimumThinking {
            try? await Task.sleep(for: minimumThinking - elapsed)
            if Task.isCancelled { return }
        }

        thinkingState = .none

        let assistantMsg = ChatMessage(role: .assistant, content: "", isStreaming: true)
        appendMessage(assistantMsg)
        let msgId = assistantMsg.id

        await streamText(responseText, toMessageId: msgId)
        if Task.isCancelled { return }

        guard let ti = threads.firstIndex(where: { $0.id == activeThreadId }),
              let mi = threads[ti].messages.firstIndex(where: { $0.id == msgId }) else { return }

        if let filters = searchFilters {
            let currentFilters = currentFindFiltersProvider?() ?? SearchFilters()
            let merged = chatService.mergeFilters(current: currentFilters, incoming: filters, addNeighborhoods: addNbhd)
            let results = chatService.searchListings(filters: merged)
            lastSearchResults = results
            threads[ti].messages[mi].searchResults = results.map { $0.id }
            threads[ti].messages[mi].searchFilters = merged
            searchResultsJustArrived = results
            searchFiltersJustArrived = merged
            searchAddNeighborhoodsJustArrived = addNbhd
        }

        if let tourReq {
            threads[ti].messages[mi].tourRequest = tourReq
        }

        if let mortgageReq {
            threads[ti].messages[mi].mortgageRequest = mortgageReq
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

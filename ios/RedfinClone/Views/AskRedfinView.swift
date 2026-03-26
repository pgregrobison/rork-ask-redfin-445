import SwiftUI

struct AskRedfinView: View {
    @Bindable var chatViewModel: ChatViewModel
    let allListings: [Listing]
    let onDismiss: () -> Void
    let onShowOnMap: ([Listing]) -> Void
    let onListingTap: (Listing) -> Void
    @FocusState private var isInputFocused: Bool
    @State private var showVoiceMode: Bool = false
    @State private var scrollPositions: [String: String] = [:]
    @State private var justSentMessageId: String?
    @State private var scrollAreaHeight: CGFloat = 0
    @State private var scrollLocked: Bool = false
    @State private var pendingScrollTarget: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messageList
                inputBar
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    threadSwitcherMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .fullScreenCover(isPresented: $showVoiceMode) {
            VoiceModeView(onDismiss: { showVoiceMode = false })
        }
    }

    private var threadSwitcherMenu: some View {
        Menu {
            Button {
                chatViewModel.createNewThread()
            } label: {
                Label("New Chat", systemImage: "plus.bubble")
            }

            if !chatViewModel.threads.isEmpty {
                Divider()
                ForEach(chatViewModel.threads) { thread in
                    Button {
                        chatViewModel.switchToThread(thread.id)
                    } label: {
                        HStack {
                            Text(thread.title)
                            if thread.id == chatViewModel.activeThreadId {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                if chatViewModel.isTourDayThread {
                    Image(systemName: "car")
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(chatViewModel.activeThread?.title ?? "Ask Redfin")
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(chatViewModel.activeMessages) { message in
                        ChatMessageBubble(
                            message: message,
                            allListings: allListings,
                            onFeedback: { feedback in
                                chatViewModel.setFeedback(feedback, for: message.id)
                            },
                            onShowOnMap: onShowOnMap,
                            onListingTap: onListingTap
                        )
                        .id(message.id)
                    }

                    if chatViewModel.thinkingState != .none {
                        ThinkingIndicator(label: chatViewModel.thinkingState.label)
                            .id("thinking")
                    }

                    if justSentMessageId != nil {
                        Color.clear
                            .frame(height: scrollAreaHeight)
                            .id("scroll-spacer")
                    }
                }
                .padding(.vertical, 16)
            }
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: ScrollAreaHeightKey.self, value: geo.size.height)
                }
            )
            .onPreferenceChange(ScrollAreaHeightKey.self) { value in
                scrollAreaHeight = value
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: pendingScrollTarget) { _, targetId in
                guard let targetId else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        proxy.scrollTo(targetId, anchor: .top)
                    }
                    pendingScrollTarget = nil
                }
            }
            .onChange(of: chatViewModel.activeMessages.count) { _, newCount in
                guard !scrollLocked else { return }
                scrollToLatest(proxy: proxy, newCount: newCount)
            }
            .onChange(of: chatViewModel.thinkingState) { _, newState in
                if newState == .none, justSentMessageId != nil {
                    justSentMessageId = nil
                    scrollLocked = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        scrollToBottom(proxy: proxy)
                    }
                }
                if newState != .none, !scrollLocked {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: chatViewModel.activeMessages.last?.content) { _, _ in
                guard !scrollLocked else { return }
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: chatViewModel.activeThreadId) { oldId, _ in
                if let oldId, let lastVisible = chatViewModel.threads.first(where: { $0.id == oldId })?.messages.last?.id {
                    scrollPositions[oldId] = lastVisible
                }
                if let currentId = chatViewModel.activeThreadId, let savedId = scrollPositions[currentId] {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        proxy.scrollTo(savedId, anchor: .bottom)
                    }
                }
            }
        }
    }


    private var canSend: Bool {
        !chatViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasActionButton: Bool {
        chatViewModel.thinkingState != .none || (chatViewModel.isTourDayThread && !canSend) || canSend
    }

    private var inputBar: some View {
        TextField("Ask or search anything", text: $chatViewModel.inputText, axis: .vertical)
            .font(.body)
            .lineLimit(1...4)
            .focused($isInputFocused)
            .onSubmit {
                sendAndScroll()
            }
            .padding(.leading, 16)
            .padding(.trailing, hasActionButton ? 54 : 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(alignment: .bottomTrailing) {
                Group {
                    if chatViewModel.thinkingState != .none {
                        Button {
                            chatViewModel.stopStreaming()
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color(.systemBackground))
                                .frame(width: 44, height: 44)
                                .background(Color.primary)
                                .clipShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else if chatViewModel.isTourDayThread && !canSend {
                        Button { showVoiceMode = true } label: {
                            Image(systemName: "mic.fill")
                                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else if canSend {
                        Button {
                            sendAndScroll()
                        } label: {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color(.systemBackground))
                                .frame(width: 44, height: 44)
                                .background(Color.primary)
                                .clipShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: canSend)
                .animation(.easeInOut(duration: 0.15), value: chatViewModel.thinkingState != .none)
                .padding(.trailing, 4)
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }

    private func sendAndScroll() {
        let willSendText = chatViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !willSendText.isEmpty else { return }
        isInputFocused = false
        chatViewModel.sendMessage()
        if let lastUserMsg = chatViewModel.activeMessages.last(where: { $0.role == .user }) {
            justSentMessageId = lastUserMsg.id
            scrollLocked = true
            pendingScrollTarget = lastUserMsg.id
        }
    }

    private func scrollToLatest(proxy: ScrollViewProxy, newCount: Int) {
        let messages = chatViewModel.activeMessages
        guard !messages.isEmpty else { return }
        let lastMessage = messages[messages.count - 1]
        if lastMessage.role == .user {
            return
        } else if justSentMessageId == nil {
            scrollToBottom(proxy: proxy)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if chatViewModel.thinkingState != .none {
                proxy.scrollTo("thinking", anchor: .bottom)
            } else if let lastId = chatViewModel.activeMessages.last?.id {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}

private struct ScrollAreaHeightKey: PreferenceKey {
    nonisolated static let defaultValue: CGFloat = 0
    nonisolated static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

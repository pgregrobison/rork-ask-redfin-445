import SwiftUI

private enum ChatScrollPhase: Equatable {
    case idle
    case userJustSent(messageId: String)
    case streaming
}

struct AskRedfinView: View {
    @Bindable var chatViewModel: ChatViewModel
    let allListings: [Listing]
    let onDismiss: () -> Void
    let onShowOnMap: ([Listing]) -> Void
    let onListingTap: (Listing) -> Void
    @FocusState private var isInputFocused: Bool
    @State private var showVoiceMode: Bool = false
    @State private var scrollPositions: [String: String] = [:]
    @State private var scrollPhase: ChatScrollPhase = .idle
    @State private var visibleHeight: CGFloat = 0
    @State private var bottomSpacerHeight: CGFloat = 0
    @State private var scrollToTopTrigger: String?

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
                VStack(spacing: 16) {
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

                    Color.clear
                        .frame(height: bottomSpacerHeight)
                        .id("bottom-spacer")
                }
                .padding(.vertical, 16)
            }
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear { visibleHeight = geo.size.height }
                        .onChange(of: geo.size.height) { _, newH in visibleHeight = newH }
                }
            )
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: scrollToTopTrigger) { _, targetId in
                guard let targetId else { return }
                scrollToTopTrigger = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        proxy.scrollTo(targetId, anchor: .top)
                    }
                }
            }
            .onChange(of: chatViewModel.activeMessages.count) { oldCount, newCount in
                guard newCount > oldCount else { return }
                let messages = chatViewModel.activeMessages
                guard let last = messages.last else { return }

                if last.role == .user {
                    return
                }

                switch scrollPhase {
                case .userJustSent:
                    scrollPhase = .streaming
                    scrollToBottom(proxy: proxy)
                case .idle:
                    scrollToBottom(proxy: proxy)
                case .streaming:
                    break
                }
            }
            .onChange(of: chatViewModel.thinkingState) { _, newState in
                switch scrollPhase {
                case .userJustSent:
                    if newState != .none {
                        scrollToBottom(proxy: proxy)
                    }
                case .streaming:
                    if newState == .none {
                        collapseSpacerAndScrollToBottom(proxy: proxy)
                    } else {
                        scrollToBottom(proxy: proxy)
                    }
                case .idle:
                    if newState != .none {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            .onChange(of: chatViewModel.activeMessages.last?.content) { _, _ in
                if case .idle = scrollPhase {
                    scrollToBottom(proxy: proxy)
                }
                if case .streaming = scrollPhase {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: chatViewModel.activeMessages.last?.isStreaming) { _, isStreaming in
                if isStreaming == false, case .streaming = scrollPhase {
                    collapseSpacerAndScrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: chatViewModel.activeThreadId) { oldId, _ in
                if let oldId, let lastVisible = chatViewModel.threads.first(where: { $0.id == oldId })?.messages.last?.id {
                    scrollPositions[oldId] = lastVisible
                }
                bottomSpacerHeight = 0
                scrollPhase = .idle
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
        guard let lastUserMsg = chatViewModel.activeMessages.last(where: { $0.role == .user }) else { return }

        let msgId = lastUserMsg.id
        scrollPhase = .userJustSent(messageId: msgId)
        bottomSpacerHeight = max(visibleHeight - 80, 200)
        scrollToTopTrigger = msgId
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

    private func collapseSpacerAndScrollToBottom(proxy: ScrollViewProxy) {
        scrollPhase = .idle
        withAnimation(.easeOut(duration: 0.3)) {
            bottomSpacerHeight = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            scrollToBottom(proxy: proxy)
        }
    }
}

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
                }
                .padding(.vertical, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: chatViewModel.activeMessages.count) { _, newCount in
                scrollToLatest(proxy: proxy, newCount: newCount)
            }
            .onChange(of: chatViewModel.thinkingState) { _, newState in
                if newState != .none {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: chatViewModel.activeMessages.last?.content) { _, _ in
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

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask or search anything", text: $chatViewModel.inputText, axis: .vertical)
                .font(.body)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .onSubmit {
                    chatViewModel.sendMessage()
                }

            if chatViewModel.thinkingState != .none {
                Button {
                    chatViewModel.stopStreaming()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 34, height: 34)
                        .contentShape(Circle())
                }
                .transition(.scale.combined(with: .opacity))
            } else if chatViewModel.isTourDayThread && !canSend {
                Button { showVoiceMode = true } label: {
                    Image(systemName: "mic.fill")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 34, height: 34)
                        .contentShape(Circle())
                }
                .transition(.scale.combined(with: .opacity))
            }

            if canSend {
                Button {
                    chatViewModel.sendMessage()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(.systemBackground))
                        .frame(width: 34, height: 34)
                        .background(Color.primary)
                        .clipShape(Circle())
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: canSend)
        .animation(.easeInOut(duration: 0.15), value: chatViewModel.thinkingState != .none)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .adaptiveGlass(in: .capsule)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func scrollToLatest(proxy: ScrollViewProxy, newCount: Int) {
        let messages = chatViewModel.activeMessages
        guard !messages.isEmpty else { return }
        let lastMessage = messages[messages.count - 1]
        if lastMessage.role == .user {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(lastMessage.id, anchor: .top)
            }
        } else {
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

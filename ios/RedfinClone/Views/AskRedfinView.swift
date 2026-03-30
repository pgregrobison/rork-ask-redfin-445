import SwiftUI



struct AskRedfinView: View {
    @Bindable var chatViewModel: ChatViewModel
    let allListings: [Listing]
    let savedListingIDs: Set<String>
    let onToggleSave: (Listing) -> Void
    let onDismiss: () -> Void
    let onShowOnMap: ([Listing]) -> Void
    let onListingTap: (Listing) -> Void
    @FocusState private var isInputFocused: Bool
    @State private var showVoiceMode: Bool = false
    @State private var scrollToTopTrigger: String?
    @State private var hasRestoredScroll: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
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
                            savedListingIDs: savedListingIDs,
                            onToggleSave: onToggleSave,
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
                        .frame(height: currentBottomSpacerHeight)
                        .id("bottom-spacer")
                }
                .padding(.vertical, 16)
            }
            .contentMargins(.bottom, 72)
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                guard !hasRestoredScroll else { return }
                hasRestoredScroll = true
                if let threadId = chatViewModel.activeThreadId,
                   let savedId = chatViewModel.scrollPositions[threadId] {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        proxy.scrollTo(savedId, anchor: .bottom)
                    }
                }
            }
            .onDisappear {
                saveCurrentScrollPosition()
                hasRestoredScroll = false
            }
            .onChange(of: scrollToTopTrigger) { _, targetId in
                guard let targetId else { return }
                scrollToTopTrigger = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        proxy.scrollTo(targetId, anchor: .top)
                    }
                }
            }
            .onChange(of: chatViewModel.activeThreadId) { oldId, _ in
                if let oldId, let lastVisible = chatViewModel.threads.first(where: { $0.id == oldId })?.messages.last?.id {
                    chatViewModel.scrollPositions[oldId] = lastVisible
                }
                if let threadId = chatViewModel.activeThreadId {
                    chatViewModel.bottomSpacerHeights[threadId] = 0
                }
                if let currentId = chatViewModel.activeThreadId, let savedId = chatViewModel.scrollPositions[currentId] {
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
        true
    }

    private var inputBar: some View {
        TextField("Ask or search anything", text: $chatViewModel.inputText, axis: .vertical)
            .font(.body)
            .lineSpacing(7)
            .frame(minHeight: 24)
            .lineLimit(1...4)
            .focused($isInputFocused)
            .onSubmit {
                sendAndScroll()
            }
            .padding(.leading, 16)
            .padding(.trailing, hasActionButton ? 54 : 16)
            .padding(.vertical, 12)
            .background(
                inputBackground
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
                    } else {
                        Button { showVoiceMode = true } label: {
                            Image(systemName: "waveform")
                                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: canSend)
                .animation(.easeInOut(duration: 0.15), value: chatViewModel.thinkingState != .none)
                .padding(.trailing, 2)
                .padding(.bottom, 2)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private var inputBackground: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.clear)
                .glassEffect(in: .capsule)
        } else {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }

    private var currentBottomSpacerHeight: CGFloat {
        guard let threadId = chatViewModel.activeThreadId else { return 0 }
        return chatViewModel.bottomSpacerHeights[threadId] ?? 0
    }

    private func saveCurrentScrollPosition() {
        guard let threadId = chatViewModel.activeThreadId,
              let lastMsgId = chatViewModel.activeMessages.last?.id else { return }
        chatViewModel.scrollPositions[threadId] = lastMsgId
    }

    private func sendAndScroll() {
        let willSendText = chatViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !willSendText.isEmpty else { return }
        isInputFocused = false
        chatViewModel.sendMessage()
        guard let lastUserMsg = chatViewModel.activeMessages.last(where: { $0.role == .user }) else { return }

        let msgId = lastUserMsg.id
        if let threadId = chatViewModel.activeThreadId {
            chatViewModel.bottomSpacerHeights[threadId] = UIScreen.main.bounds.height
        }
        scrollToTopTrigger = msgId
    }


}

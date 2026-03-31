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
    @State private var scrollToTopTrigger: String?
    @State private var scrollToBottomTrigger: String?
    @State private var hasRestoredScroll: Bool = false

    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        ZStack(alignment: .bottom) {
            messageList
            inputFooter
        }
        .background(Color(.systemBackground))
        .environment(\.horizontalSizeClass, .regular)
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
    }

    private var headerBar: some View {
        HStack {
            threadSwitcherMenu
            Spacer()
            GlassActionButton(icon: "xmark", action: onDismiss)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(.systemBackground), location: 0),
                    .init(color: Color(.systemBackground).opacity(0.6), location: 0.4),
                    .init(color: Color(.systemBackground).opacity(0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.bottom, -20)
            .allowsHitTesting(false),
            alignment: .top
        )
    }

    @ViewBuilder
    private var threadSwitcherMenu: some View {
        if #available(iOS 26.0, *) {
            threadSwitcherMenuContent
                .glassEffect(in: .capsule)
        } else {
            threadSwitcherMenuContent
                .background(.ultraThinMaterial, in: Capsule())
        }
    }

    private var threadSwitcherMenuContent: some View {
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
                Text(truncatedTitle)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .frame(height: 44)
            .padding(.horizontal, 14)
        }
        .tint(.primary)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Color.clear.frame(height: 0)
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
                            onListingTap: onListingTap,
                            carouselScrollPosition: Binding(
                                get: { chatViewModel.carouselScrollPositions[message.id] },
                                set: { chatViewModel.carouselScrollPositions[message.id] = $0 }
                            )
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
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .contentMargins(.top, 0)
            .contentMargins(.bottom, chatViewModel.isVoiceModeActive ? 220 : 72)
            .safeAreaInset(edge: .top, spacing: 0) {
                headerBar
            }
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
            .onChange(of: chatViewModel.voiceScrollToTopId) { _, targetId in
                guard let targetId else { return }
                chatViewModel.voiceScrollToTopId = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        proxy.scrollTo(targetId, anchor: .top)
                    }
                }
            }
            .onChange(of: scrollToBottomTrigger) { _, targetId in
                guard let targetId else { return }
                scrollToBottomTrigger = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        proxy.scrollTo(targetId, anchor: .bottom)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .chatWidgetFieldFocused)) { notification in
                guard let msgID = notification.userInfo?["messageID"] as? String else { return }
                scrollToBottomTrigger = msgID
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

    private var inputFooter: some View {
        VStack(spacing: 0) {
            if chatViewModel.isVoiceModeActive {
                InlineVoiceOrb(isListening: !chatViewModel.isVoiceMuted)
                    .transition(.scale(scale: 0.3).combined(with: .opacity))
                    .padding(.bottom, 12)
            }

            inputBar
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: chatViewModel.isVoiceModeActive)
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Ask or search anything", text: $chatViewModel.inputText, axis: .vertical)
                .font(.body)
                .lineSpacing(7)
                .frame(minHeight: 24)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .disabled(chatViewModel.isVoiceModeActive)
                .opacity(chatViewModel.isVoiceModeActive ? 0.4 : 1)
                .onSubmit {
                    sendAndScroll()
                }
                .padding(.leading, 16)
                .padding(.trailing, chatViewModel.isVoiceModeActive ? 12 : 54)
                .padding(.vertical, 12)
                .background(
                    inputBackground
                )
                .overlay(alignment: .bottomTrailing) {
                    if !chatViewModel.isVoiceModeActive {
                        HStack(spacing: 4) {
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
                                Button {
                                    isInputFocused = false
                                    chatViewModel.activateVoiceMode()
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                } label: {
                                    Image(systemName: "waveform")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color(.systemBackground))
                                        .frame(width: 44, height: 44)
                                        .background(Color.primary)
                                        .clipShape(Circle())
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: canSend)
                        .animation(.easeInOut(duration: 0.15), value: chatViewModel.thinkingState != .none)
                        .padding(.trailing, 2)
                        .padding(.bottom, 2)
                    }
                }

            if chatViewModel.isVoiceModeActive {
                Button {
                    chatViewModel.toggleVoiceMute()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: chatViewModel.isVoiceMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(chatViewModel.isVoiceMuted ? .white : .primary)
                        .frame(width: 44, height: 44)
                        .background(chatViewModel.isVoiceMuted ? Color.red : Color(.tertiarySystemFill))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))

                Button {
                    chatViewModel.deactivateVoiceMode()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(.systemBackground))
                        .frame(width: 44, height: 44)
                        .background(Color.primary)
                        .clipShape(Circle())
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: chatViewModel.isVoiceModeActive)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: chatViewModel.isVoiceMuted)
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

    private var truncatedTitle: String {
        let title = chatViewModel.activeThread?.title ?? "Ask Redfin"
        if title.count > 15 {
            return String(title.prefix(15)) + "…"
        }
        return title
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

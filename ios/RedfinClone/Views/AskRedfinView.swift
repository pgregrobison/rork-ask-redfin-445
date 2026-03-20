import SwiftUI

struct AskRedfinView: View {
    @Bindable var chatViewModel: ChatViewModel
    let allListings: [Listing]
    let onDismiss: () -> Void
    let onShowOnMap: ([Listing]) -> Void
    let onListingTap: (Listing) -> Void
    @FocusState private var isInputFocused: Bool
    @State private var showVoiceMode: Bool = false

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
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
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
                Image(systemName: chatViewModel.isTourDayThread ? "car" : "sparkle")
                    .font(.system(size: 12, weight: .semibold))
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
                    if chatViewModel.activeMessages.isEmpty {
                        emptyState
                    }

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
            .onChange(of: chatViewModel.activeMessages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: chatViewModel.thinkingState) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: chatViewModel.activeMessages.last?.content) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)

            Image(systemName: "sparkle")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)

            Text("Ask Redfin")
                .font(.title2.bold())

            Text("Your AI real estate assistant for NYC.\nSearch homes, schedule tours, or get prequalified.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                suggestionButton("Show me condos under $1.5M in Manhattan")
                suggestionButton("I want to schedule a tour")
                suggestionButton("Help me get prequalified for a mortgage")
                suggestionButton("What are the hot homes right now?")
            }
            .padding(.top, 8)

            Spacer().frame(height: 40)
        }
        .padding(.horizontal, 20)
    }

    private func suggestionButton(_ text: String) -> some View {
        Button {
            chatViewModel.inputText = text
            chatViewModel.sendMessage()
        } label: {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 12))
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)

            TextField("Ask or search anything", text: $chatViewModel.inputText, axis: .vertical)
                .font(.body)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .onSubmit {
                    chatViewModel.sendMessage()
                }

            if chatViewModel.isTourDayThread {
                Button { showVoiceMode = true } label: {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }

            if chatViewModel.thinkingState != .none {
                Button {
                    chatViewModel.stopStreaming()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6), in: .capsule)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
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

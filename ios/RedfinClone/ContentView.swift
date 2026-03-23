import SwiftUI

struct ContentView: View {
    @State private var viewModel = ListingsViewModel()
    @State private var chatViewModel = ChatViewModel()
    @State private var selectedTab: AppTab = .find
    @State private var navigationPath = NavigationPath()
    @State private var showTabBar: Bool = true
    @State private var showNudge: Bool = false
    @State private var nudgeShownThisSession: Bool = false
    @State private var nudgeText: String = ""
    private let nudgeFullText = "Ask me about homes in NYC!"

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                tabContent

                if showTabBar {
                    VStack(spacing: 8) {
                        if showNudge {
                            nudgeBubble
                                .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .bottom)))
                        }

                        CustomTabBar(
                            selectedTab: $selectedTab,
                            onFABTap: {
                                dismissNudge()
                                viewModel.showChat = true
                            }
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onChange(of: viewModel.selectedListing?.id) { _, newValue in
                withAnimation(.easeInOut(duration: 0.25)) {
                    showTabBar = newValue == nil
                }
            }
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(
                    listing: listing,
                    isSaved: viewModel.isSaved(listing),
                    onToggleSave: { viewModel.toggleSaved(listing) }
                )
                .toolbar(.hidden, for: .tabBar)
                .onAppear { withAnimation(.easeOut(duration: 0.2)) { showTabBar = false } }
                .onDisappear { withAnimation(.easeOut(duration: 0.2)) { showTabBar = true } }
            }
        }
        .tint(.primary)
        .sheet(isPresented: $viewModel.showChat) {
            AskRedfinView(
                chatViewModel: chatViewModel,
                allListings: viewModel.listings,
                onDismiss: {
                    viewModel.showChat = false
                },
                onShowOnMap: { listings in
                    viewModel.showChat = false
                    selectedTab = .find
                    viewModel.showListView = false
                    if let first = listings.first {
                        viewModel.selectListing(first)
                    }
                },
                onListingTap: { listing in
                    viewModel.showChat = false
                    viewModel.markSeen(listing)
                    navigationPath.append(listing)
                }
            )
        }
        .onAppear {
            startNudgeTimer()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .find:
            FindView(viewModel: viewModel) { listing in
                viewModel.markSeen(listing)
                navigationPath.append(listing)
            }
        case .forYou:
            ForYouView(viewModel: viewModel) { listing in
                viewModel.markSeen(listing)
                navigationPath.append(listing)
            }
        case .saved:
            SavedView(viewModel: viewModel) { listing in
                viewModel.markSeen(listing)
                navigationPath.append(listing)
            }
        case .myHome:
            MyHomeView()
        }
    }

    private var nudgeBubble: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(nudgeText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .adaptiveGlassInteractive(in: .rect(cornerRadius: 14))
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            .padding(.trailing, 16)
        }
    }

    private func startNudgeTimer() {
        guard !nudgeShownThisSession else { return }
        Task {
            try? await Task.sleep(for: .seconds(3))
            guard !nudgeShownThisSession else { return }
            nudgeShownThisSession = true

            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showNudge = true
            }

            for i in 1...nudgeFullText.count {
                try? await Task.sleep(for: .milliseconds(40))
                nudgeText = String(nudgeFullText.prefix(i))
            }

            try? await Task.sleep(for: .seconds(8))
            dismissNudge()
        }
    }

    private func dismissNudge() {
        withAnimation(.easeOut(duration: 0.3)) {
            showNudge = false
        }
    }
}

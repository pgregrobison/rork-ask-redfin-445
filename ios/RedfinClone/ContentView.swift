import SwiftUI

struct ContentView: View {
    @State private var viewModel = ListingsViewModel()
    @State private var chatViewModel = ChatViewModel()
    @State private var debugSettings = DebugSettings()
    @State private var selectedTab: AppTab = .find
    @State private var navigationPath = NavigationPath()
    @State private var showTabBar: Bool = true
    @State private var pendingMapListings: [Listing]?
    @State private var fluidGrowListing: Listing?
    @State private var fluidGrowVisible: Bool = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                tabContent

                if showTabBar {
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        onFABTap: {
                            viewModel.showChat = true
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .ignoresSafeArea(.keyboard)
            .onChange(of: viewModel.selectedListing?.id) { _, newValue in
                withAnimation(.easeInOut(duration: 0.25)) {
                    showTabBar = newValue == nil
                }
            }
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(
                    listing: listing,
                    isSaved: viewModel.isSaved(listing),
                    onToggleSave: { viewModel.toggleSaved(listing) },
                    onAskRedfin: { viewModel.showChat = true }
                )
                .toolbar(.hidden, for: .tabBar)
                .onAppear { withAnimation(.easeOut(duration: 0.2)) { showTabBar = false } }
                .onDisappear { if viewModel.selectedListing == nil { withAnimation(.easeOut(duration: 0.2)) { showTabBar = true } } }
            }
        }
        .tint(.primary)
        .overlay {
            if let listing = fluidGrowListing {
                FluidGrowDetailView(
                    listing: listing,
                    isVisible: fluidGrowVisible,
                    isSaved: viewModel.isSaved(listing),
                    onToggleSave: { viewModel.toggleSaved(listing) },
                    onAskRedfin: { viewModel.showChat = true },
                    onDismiss: { dismissFluidGrow() }
                )
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.88), value: fluidGrowListing?.id)
        .sheet(isPresented: $viewModel.showChat, onDismiss: {
            if let listings = pendingMapListings {
                pendingMapListings = nil
                viewModel.fitListings(listings)
            }
        }) {
            AskRedfinView(
                chatViewModel: chatViewModel,
                allListings: viewModel.listings,
                savedListingIDs: viewModel.savedListingIDs,
                onToggleSave: { listing in viewModel.toggleSaved(listing) },
                onDismiss: {
                    viewModel.showChat = false
                },
                onShowOnMap: { listings in
                    pendingMapListings = listings
                    selectedTab = .find
                    viewModel.showListView = false
                    viewModel.dismissOverlay()
                    viewModel.showChat = false
                },
                onListingTap: { listing in
                    viewModel.showChat = false
                    viewModel.markSeen(listing)
                    navigationPath.append(listing)
                }
            )
        }
        .onChange(of: viewModel.notificationService.pendingCompassListingID) { _, newID in
            guard let listingID = newID else { return }
            viewModel.notificationService.pendingCompassListingID = nil
            viewModel.showChat = false
            navigationPath = NavigationPath()
            selectedTab = .find
            viewModel.showListView = false
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                if let listing = viewModel.listings.first(where: { $0.id == listingID }) {
                    viewModel.selectedListing = listing
                    viewModel.markSeen(listing)
                    viewModel.fitUserAndListing(listing)
                } else {
                    viewModel.selectNearestCompassListing(to: nil)
                }
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .find:
            FindView(viewModel: viewModel) { listing in
                navigateToListing(listing)
            }
        case .forYou:
            ForYouView(viewModel: viewModel) { listing in
                navigateToListing(listing)
            }
        case .saved:
            SavedView(viewModel: viewModel) { listing in
                navigateToListing(listing)
            }
        case .myHome:
            MyHomeView(debugSettings: debugSettings)
        }
    }

    private func navigateToListing(_ listing: Listing) {
        viewModel.markSeen(listing)
        switch debugSettings.cardTransition {
        case .nativePush:
            navigationPath.append(listing)
        case .fluidGrow:
            fluidGrowListing = listing
            withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                fluidGrowVisible = true
            }
            withAnimation(.easeOut(duration: 0.2)) {
                showTabBar = false
            }
        }
    }

    private func dismissFluidGrow() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            fluidGrowVisible = false
        }
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            fluidGrowListing = nil
            if viewModel.selectedListing == nil {
                withAnimation(.easeOut(duration: 0.2)) {
                    showTabBar = true
                }
            }
        }
    }
}

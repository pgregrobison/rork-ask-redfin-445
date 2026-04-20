import SwiftUI

struct ContentView: View {
    @State private var viewModel = ListingsViewModel()
    @State private var chatViewModel = ChatViewModel()
    @State private var debugSettings = DebugSettings()
    @State private var selectedTab: AppTab = .find

    @State private var navigationPath = NavigationPath()
    @State private var showTabBar: Bool = true
    @State private var pendingMapListings: [Listing]?
    @State private var showLocationMenu: Bool = false
    @State private var chatDetent: PresentationDetent = .large
    @State private var showDebugPanel: Bool = false
    @Namespace private var zoomNamespace

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
            .onChange(of: viewModel.isCardVisible) { _, visible in
                withAnimation(.easeInOut(duration: 0.25)) {
                    showTabBar = !visible
                }
            }
            .navigationDestination(for: Listing.self) { listing in
                listingDetail(for: listing)
            }
        }
        .overlay(alignment: .top) {
            if selectedTab == .find && navigationPath.isEmpty {
                FindPillOverlay(viewModel: viewModel, showLocationMenu: $showLocationMenu)
            }
        }
        .tint(.primary)
        .onAppear {
            viewModel.debugSettings = debugSettings
            chatViewModel.debugSettings = debugSettings
        }
        .sheet(isPresented: $showDebugPanel) {
            DebugPanelView(settings: debugSettings)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showChat, onDismiss: {
            if let listings = pendingMapListings {
                pendingMapListings = nil
                viewModel.fitListings(listings)
            }
            chatDetent = .large
        }) {
            AskRedfinView(
                chatViewModel: chatViewModel,
                allListings: viewModel.listings,
                savedListingIDs: viewModel.savedListingIDs,
                onToggleSave: { listing in viewModel.toggleSaved(listing) },
                onDismiss: {
                    viewModel.showChat = false
                },
                onShowOnMap: { listings, filters in
                    if let filters, debugSettings.realisticModeEnabled, debugSettings.realisticSyncMode == .oneWay {
                        viewModel.applyChatFilters(filters, merge: true)
                        pendingMapListings = viewModel.filteredListings
                    } else {
                        pendingMapListings = listings
                    }
                    selectedTab = .find
                    viewModel.showListView = false
                    viewModel.dismissOverlay()
                    viewModel.showChat = false
                },
                onListingTap: { listing in
                    viewModel.showChat = false
                    viewModel.markSeen(listing)
                    navigationPath.append(listing)
                },
                mapFocusActive: isMapFocusEligible,
                selectedDetent: $chatDetent,
                zoomNamespace: zoomNamespace
            )
        }
        .onChange(of: chatViewModel.searchResultsJustArrived) { _, results in
            guard let results, !results.isEmpty else { return }
            let filters = chatViewModel.searchFiltersJustArrived
            let isBidirectional = debugSettings.realisticModeEnabled && debugSettings.realisticSyncMode == .bidirectional

            if isMapFocusEligible {
                chatViewModel.searchResultsJustArrived = nil
                chatViewModel.searchFiltersJustArrived = nil
                if isBidirectional, let filters {
                    viewModel.applyChatFilters(filters, merge: false)
                }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    chatDetent = .fraction(0.7)
                }
                Task {
                    try? await Task.sleep(for: .milliseconds(350))
                    let targetListings = isBidirectional ? viewModel.filteredListings : results
                    viewModel.fitListings(targetListings, sheetFraction: 0.7)
                }
                return
            }

            if isBidirectional {
                chatViewModel.searchResultsJustArrived = nil
                chatViewModel.searchFiltersJustArrived = nil
                if let filters {
                    viewModel.applyChatFilters(filters, merge: false)
                    pendingMapListings = viewModel.filteredListings
                } else {
                    pendingMapListings = results
                }
                selectedTab = .find
                viewModel.showListView = false
                viewModel.dismissOverlay()
            }
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
        ZStack {
            FindView(viewModel: viewModel, zoomNamespace: zoomNamespace, isActive: selectedTab == .find, onProfileTap: { showDebugPanel = true }) { listing in
                navigateToListing(listing)
            }
            .opacity(selectedTab == .find ? 1 : 0)
            .allowsHitTesting(selectedTab == .find)

            ForYouView(viewModel: viewModel, zoomNamespace: zoomNamespace, isActive: selectedTab == .forYou, onProfileTap: { showDebugPanel = true }) { listing in
                navigateToListing(listing)
            }
            .opacity(selectedTab == .forYou ? 1 : 0)
            .allowsHitTesting(selectedTab == .forYou)

            SavedView(viewModel: viewModel, zoomNamespace: zoomNamespace, isActive: selectedTab == .saved, onProfileTap: { showDebugPanel = true }) { listing in
                navigateToListing(listing)
            }
            .opacity(selectedTab == .saved ? 1 : 0)
            .allowsHitTesting(selectedTab == .saved)

            MyHomeView(isActive: selectedTab == .myHome, onProfileTap: { showDebugPanel = true })
                .opacity(selectedTab == .myHome ? 1 : 0)
                .allowsHitTesting(selectedTab == .myHome)
        }
    }

    @ViewBuilder
    private func listingDetail(for listing: Listing) -> some View {
        let detail = detailView(for: listing)
            .toolbar(.hidden, for: .tabBar)
            .onAppear { withAnimation(.easeOut(duration: 0.2)) { showTabBar = false } }
            .onDisappear { if !viewModel.isCardVisible { withAnimation(.easeOut(duration: 0.2)) { showTabBar = true } } }

        if debugSettings.cardTransition == .zoom {
            detail.navigationTransition(.zoom(sourceID: listing.id, in: zoomNamespace))
        } else {
            detail
        }
    }

    @ViewBuilder
    private func detailView(for listing: Listing) -> some View {
        switch debugSettings.detailPageStyle {
        case .current:
            ListingDetailView(
                listing: listing,
                isSaved: viewModel.isSaved(listing),
                useZoomTransition: debugSettings.cardTransition == .zoom,
                onToggleSave: { viewModel.toggleSaved(listing) },
                onAskRedfin: { viewModel.showChat = true }
            )
        case .james:
            RedfinDetailView(
                listing: listing,
                isSaved: viewModel.isSaved(listing),
                useZoomTransition: debugSettings.cardTransition == .zoom,
                onToggleSave: { viewModel.toggleSaved(listing) },
                onAskRedfin: { viewModel.showChat = true }
            )
        }
    }

    private var isMapFocusEligible: Bool {
        debugSettings.searchBehavior == .mapFocus
            && selectedTab == .find
            && !viewModel.showListView
    }

    private func navigateToListing(_ listing: Listing) {
        viewModel.markSeen(listing)
        navigationPath.append(listing)
    }
}

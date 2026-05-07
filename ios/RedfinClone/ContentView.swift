import SwiftUI

struct ContentView: View {
    @State private var viewModel = ListingsViewModel()
    @State private var chatViewModel = ChatViewModel()
    @State private var debugSettings = DebugSettings()
    @State private var myHomeDraft = OTOSetupDraft()
    @State private var askRedfinContext = AskRedfinContextModel()
    @State private var selectedTab: AppTab = .find

    @State private var navigationPath = NavigationPath()
    @State private var forYouPath = NavigationPath()
    @State private var savedPath = NavigationPath()
    @State private var myHomePath = NavigationPath()
    @State private var myRedfinPath = NavigationPath()
    @State private var showTabBar: Bool = true
    @State private var stickyMinimized: Bool = false
    @State private var pendingMapListings: [Listing]?
    @State private var pendingNeighborhoodFocus: [String]?
    @State private var showLocationMenu: Bool = false
    @State private var chatDetent: PresentationDetent = .large
    @State private var showDebugPanel: Bool = false
    @Namespace private var zoomNamespace

    var body: some View {
        rootLayout
            .environment(\.askRedfinContext, askRedfinContext)
            .overlay(alignment: .top) {
                if selectedTab == .find && navigationPath.isEmpty {
                    FindPillOverlay(viewModel: viewModel, showLocationMenu: $showLocationMenu)
                }
            }
        .tint(.primary)
        .onAppear {
            viewModel.debugSettings = debugSettings
            chatViewModel.debugSettings = debugSettings
            chatViewModel.currentFindFiltersProvider = { [weak viewModel] in
                viewModel?.currentSearchFilters ?? SearchFilters()
            }
            chatViewModel.requestTourDayNotificationHandler = { [weak viewModel] in
                viewModel?.notificationService.scheduleTourDayNotification()
            }
            if viewModel.notificationService.pendingTourDayTrigger > 0 {
                handleTourDayTrigger()
            }
        }
        .onChange(of: viewModel.notificationService.pendingTourDayTrigger) { _, newCount in
            guard newCount > 0 else { return }
            handleTourDayTrigger()
        }
        .sheet(isPresented: $showDebugPanel) {
            DebugPanelView(settings: debugSettings)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showChat, onDismiss: {
            let nbhds = pendingNeighborhoodFocus
            pendingNeighborhoodFocus = nil
            if let listings = pendingMapListings {
                pendingMapListings = nil
                if let nbhds, !nbhds.isEmpty {
                    viewModel.fitNeighborhoods(nbhds)
                } else {
                    viewModel.fitListings(listings)
                }
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
                onShowOnMap: { listings, _ in
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
                },
                mapFocusActive: isMapFocusEligible,
                selectedDetent: $chatDetent,
                zoomNamespace: zoomNamespace
            )
        }
        .onChange(of: chatViewModel.searchResultsJustArrived) { _, results in
            guard let results, !results.isEmpty else { return }

            if isMapFocusEligible {
                chatViewModel.searchResultsJustArrived = nil
                chatViewModel.searchFiltersJustArrived = nil
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    chatDetent = .fraction(0.7)
                }
                Task {
                    try? await Task.sleep(for: .milliseconds(350))
                    viewModel.fitListings(results, sheetFraction: 0.7)
                }
                return
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
    private var rootLayout: some View {
        if useAccessoryLayout, #available(iOS 26.0, *) {
            accessoryLayout
        } else {
            appNavLayout
        }
    }

    private var useAccessoryLayout: Bool {
        debugSettings.globalEntrypoint == .accessory
    }

    private var appNavLayout: some View {
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
    }

    @available(iOS 26.0, *)
    private var accessoryLayout: some View {
        TabView(selection: tabSelectionBinding) {
            Tab(value: AppTab.find) {
                NavigationStack(path: $navigationPath) {
                    FindView(viewModel: viewModel, zoomNamespace: zoomNamespace, isActive: selectedTab == .find, onProfileTap: {}, onListingTap: { listing in
                        navigateToListing(listing)
                    }, showShimmer: mapShimmerActive, accessoryMode: true, hideProfileButton: true)
                    .navigationDestination(for: Listing.self) { listing in
                        listingDetail(for: listing)
                    }
                }
                .tint(.primary)
            } label: {
                Label(AppTab.find.title, systemImage: AppTab.find.selectedIcon)
            }
            Tab(value: AppTab.forYou) {
                NavigationStack(path: $forYouPath) {
                    ForYouView(viewModel: viewModel, zoomNamespace: zoomNamespace, isActive: selectedTab == .forYou, onProfileTap: {}, onListingTap: { listing in
                        viewModel.markSeen(listing)
                        forYouPath.append(listing)
                    }, hideProfileButton: true, ownsNavStack: true)
                    .navigationDestination(for: Listing.self) { listing in
                        listingDetail(for: listing)
                    }
                }
                .tint(.primary)
            } label: {
                Label(AppTab.forYou.title, systemImage: AppTab.forYou.selectedIcon)
            }
            Tab(value: AppTab.saved) {
                NavigationStack(path: $savedPath) {
                    SavedView(viewModel: viewModel, zoomNamespace: zoomNamespace, isActive: selectedTab == .saved, onProfileTap: {}, onListingTap: { listing in
                        viewModel.markSeen(listing)
                        savedPath.append(listing)
                    }, hideProfileButton: true, ownsNavStack: true)
                    .navigationDestination(for: Listing.self) { listing in
                        listingDetail(for: listing)
                    }
                }
                .tint(.primary)
            } label: {
                Label(AppTab.saved.title, systemImage: AppTab.saved.selectedIcon)
            }
            Tab(value: AppTab.myHome) {
                NavigationStack(path: $myHomePath) {
                    MyHomeView(isActive: selectedTab == .myHome, onProfileTap: {}, hideProfileButton: true, ownsNavStack: true, debugSettings: debugSettings, setupDraft: myHomeDraft)
                }
                .tint(.primary)
            } label: {
                Label(AppTab.myHome.title, systemImage: AppTab.myHome.selectedIcon)
            }
            Tab(value: AppTab.myRedfin) {
                NavigationStack(path: $myRedfinPath) {
                    MyRedfinView(isActive: selectedTab == .myRedfin, onProfileTap: { showDebugPanel = true }, ownsNavStack: true)
                }
                .tint(.primary)
            } label: {
                Label(AppTab.myRedfin.title, systemImage: AppTab.myRedfin.selectedIcon)
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(Theme.Colors.brandRed)
        .tabViewBottomAccessory {
            AskRedfinAccessoryBar {
                chatViewModel.focusInputOnAppear = true
                viewModel.showChat = true
            }
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: viewModel.isCardVisible) { _, visible in
            if visible { stickyMinimized = true }
        }
        .onChange(of: viewModel.showListView) { _, showing in
            if showing { stickyMinimized = false }
        }
        .onChange(of: navigationPath.count) { _, count in
            if count == 0 { stickyMinimized = false }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        ZStack {
            FindView(viewModel: viewModel, zoomNamespace: zoomNamespace, isActive: selectedTab == .find, onProfileTap: { showDebugPanel = true }, onListingTap: { listing in
                navigateToListing(listing)
            }, showShimmer: mapShimmerActive)
            .animation(.easeInOut(duration: 0.25), value: mapShimmerActive)
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

            MyHomeView(isActive: selectedTab == .myHome, onProfileTap: { showDebugPanel = true }, debugSettings: debugSettings, setupDraft: myHomeDraft)
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

        detail.navigationTransition(.zoom(sourceID: listing.id, in: zoomNamespace))
    }

    @ViewBuilder
    private func detailView(for listing: Listing) -> some View {
        let hideFAB = debugSettings.globalEntrypoint == .accessory
        HybridDetailView(
            listing: listing,
            isSaved: viewModel.isSaved(listing),
            useZoomTransition: true,
            hideAskRedfinFAB: hideFAB,
            onToggleSave: { viewModel.toggleSaved(listing) },
            onAskRedfin: { viewModel.showChat = true }
        )
    }

    private var mapShimmerActive: Bool {
        false
    }

    private var isMapFocusEligible: Bool {
        debugSettings.searchBehavior == .mapFocus
            && selectedTab == .find
            && !viewModel.showListView
    }

    private var shouldMinimizeAccessory: Bool {
        guard selectedTab == .find,
              !viewModel.showListView,
              navigationPath.isEmpty else { return false }
        return stickyMinimized
    }

    @available(iOS 26.0, *)
    private var tabSelectionBinding: Binding<AppTab> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                stickyMinimized = false
                selectedTab = newValue
            }
        )
    }

    private func navigateToListing(_ listing: Listing) {
        viewModel.markSeen(listing)
        navigationPath.append(listing)
    }

    private func handleTourDayTrigger() {
        viewModel.notificationService.pendingTourDayTrigger = 0
        navigationPath = NavigationPath()
        selectedTab = .find
        viewModel.showListView = false
        viewModel.showChat = true
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            chatViewModel.startTourDay()
        }
    }
}

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ListingsViewModel()
    @State private var chatViewModel = ChatViewModel()
    @State private var selectedTab: AppTab = .find
    @State private var navigationPath = NavigationPath()
    @State private var showTabBar: Bool = true
    @State private var pendingMapListings: [Listing]?

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


}

import SwiftUI
import MapKit

struct FindView: View {
    @Bindable var viewModel: ListingsViewModel
    var zoomNamespace: Namespace.ID
    let onListingTap: (Listing) -> Void

    @State private var showLocationMenu: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var locationSearchService = LocationSearchService()

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if viewModel.showListView {
                    FindListView(viewModel: viewModel, zoomNamespace: zoomNamespace, onListingTap: onListingTap)
                } else {
                    FindMapView(viewModel: viewModel, zoomNamespace: zoomNamespace, onListingTap: onListingTap)
                }
            }

            if showLocationMenu {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }
            }

            expandedMenuOverlay
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.visible, for: .navigationBar)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                GlassActionButton(icon: viewModel.showListView ? "map" : "list.bullet") {
                    viewModel.showListView.toggle()
                }
            }
            ToolbarItem(placement: .principal) {
                principalPill
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    if viewModel.showListView {
                        GlassActionMenuButton(icon: "arrow.up.arrow.down") {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button {
                                    viewModel.sortOption = option
                                } label: {
                                    HStack {
                                        Text(option.rawValue)
                                        if viewModel.sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                    }
                    GlassActionButton(icon: "person.crop.circle") {}
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.showListView)
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
    }

    private var principalPill: some View {
        Button {
            if showLocationMenu {
                closeMenu()
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.88)) {
                    showLocationMenu = true
                }
            }
        } label: {
            HStack(spacing: 6) {
                if showLocationMenu {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
                VStack(spacing: 1) {
                    Text(viewModel.locationName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text("\(viewModel.filteredListings.count) homes")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minHeight: 44)
            .adaptiveGlass(in: .rect(cornerRadius: 25))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.88), value: showLocationMenu)
    }

    private var expandedMenuOverlay: some View {
        Group {
            if showLocationMenu {
                VStack(spacing: 0) {
                    LocationMenuView(
                        viewModel: viewModel,
                        searchService: locationSearchService,
                        onClose: {
                            closeMenu()
                        },
                        onOpenFilter: {
                            closeMenu()
                            showFilterSheet = true
                        }
                    )
                }
                .adaptiveGlass(in: .rect(cornerRadius: 20))
                .clipped()
                .padding(.horizontal, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.88), value: showLocationMenu)
    }

    private func closeMenu() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.88)) {
            showLocationMenu = false
        }
    }
}

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
                Group {
                    if showLocationMenu {
                        GlassActionButton(icon: "xmark") {
                            closeMenu()
                        }
                    } else {
                        HStack(spacing: 8) {
                            GlassActionButton(icon: viewModel.showListView ? "map" : "list.bullet") {
                                viewModel.showListView.toggle()
                            }
                            locationPill
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    if viewModel.showListView && !showLocationMenu {
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
                    if !showLocationMenu {
                        GlassActionButton(icon: "person.crop.circle") {}
                            .transition(.scale(scale: 0.6).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showLocationMenu)
                .animation(.easeInOut(duration: 0.2), value: viewModel.showListView)
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
    }

    private var locationPill: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.88)) {
                showLocationMenu = true
            }
        } label: {
            HStack(spacing: 6) {
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
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minHeight: 44)
            .adaptiveGlass(in: .rect(cornerRadius: 25))
        }
        .buttonStyle(.plain)
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

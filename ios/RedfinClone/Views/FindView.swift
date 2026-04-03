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

            morphingPillMenu
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.dismissOverlay()
                    viewModel.showListView.toggle()
                } label: {
                    Image(systemName: viewModel.showListView ? "map" : "list.bullet")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                }
            }
            if viewModel.showListView {
                ToolbarItem(placement: .topBarTrailing) {
                    sortMenu
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
    }

    private var sortMenu: some View {
        Menu {
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
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: Theme.IconSize.medium, weight: .semibold))
        }
    }

    private var morphingPillMenu: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                if showLocationMenu {
                    Button {
                        closeMenu()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }

                VStack(alignment: showLocationMenu ? .leading : .center, spacing: 1) {
                    Text(viewModel.locationName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text("\(viewModel.filteredListings.count) homes")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: showLocationMenu ? .infinity : nil, alignment: showLocationMenu ? .leading : .center)

                if showLocationMenu {
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, showLocationMenu ? 12 : 14)
            .padding(.vertical, showLocationMenu ? 10 : 6)
            .frame(minHeight: 44)

            if showLocationMenu {
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
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: showLocationMenu ? .infinity : nil)
        .adaptiveGlass(in: .rect(cornerRadius: showLocationMenu ? 20 : 25))
        .clipped()
        .padding(.horizontal, showLocationMenu ? 8 : 0)
        .offset(y: -54)
        .zIndex(1)
        .contentShape(.interaction, RoundedRectangle(cornerRadius: showLocationMenu ? 20 : 25))
        .onTapGesture {
            if !showLocationMenu {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.88)) {
                    showLocationMenu = true
                }
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

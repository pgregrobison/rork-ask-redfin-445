import SwiftUI
import MapKit

struct FindView: View {
    @Bindable var viewModel: ListingsViewModel
    let onListingTap: (Listing) -> Void

    @State private var showLocationMenu: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var locationSearchService = LocationSearchService()

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if viewModel.showListView {
                    FindListView(viewModel: viewModel, onListingTap: onListingTap)
                } else {
                    FindMapView(viewModel: viewModel, onListingTap: onListingTap)
                }
            }

            if showLocationMenu {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }

                expandedMenu
                    .padding(.horizontal, 8)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.88), value: showLocationMenu)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                GlassActionButton(icon: viewModel.showListView ? "map" : "list.bullet") {
                    viewModel.showListView.toggle()
                }
                .opacity(showLocationMenu ? 0 : 1)
                .animation(.easeInOut(duration: 0.15), value: showLocationMenu)
            }

            ToolbarItem(placement: .principal) {
                locationPill
                    .opacity(showLocationMenu ? 0 : 1)
                    .animation(.easeInOut(duration: 0.15), value: showLocationMenu)
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
                .opacity(showLocationMenu ? 0 : 1)
                .animation(.easeInOut(duration: 0.15), value: showLocationMenu)
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView()
                .presentationDetents([.medium, .large])
        }
    }

    private var locationPill: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.88)) {
                showLocationMenu = true
            }
        } label: {
            VStack(spacing: 1) {
                Text(viewModel.locationName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("\(viewModel.listings.count) homes")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minHeight: 44)
            .adaptiveGlass(in: .capsule)
        }
        .buttonStyle(.plain)
    }

    private var expandedMenu: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
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

                VStack(alignment: .leading, spacing: 1) {
                    Text(viewModel.locationName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text("\(viewModel.listings.count) homes")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 44)

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
    }

    private func closeMenu() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.88)) {
            showLocationMenu = false
        }
    }
}

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
            }

            morphingPillMenu
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.showListView.toggle()
                } label: {
                    Image(systemName: viewModel.showListView ? "map" : "list.bullet")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                        .contentTransition(.symbolEffect(.replace))
                }
            }

            ToolbarItem(placement: .principal) {
                Color.clear
                    .frame(width: 1, height: 1)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView()
                .presentationDetents([.medium, .large])
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
                    Text("\(viewModel.listings.count) homes")
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
        .padding(.horizontal, showLocationMenu ? 8 : 0)
        .padding(.top, 4)
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

import SwiftUI
import MapKit

struct FindView: View {
    @Bindable var viewModel: ListingsViewModel
    let onListingTap: (Listing) -> Void

    @State private var showLocationMenu: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var locationSearchService = LocationSearchService()
    @Namespace private var menuNamespace

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

            headerOverlay
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView()
                .presentationDetents([.medium, .large])
        }
    }

    private var headerOverlay: some View {
        VStack(spacing: 0) {
            if showLocationMenu {
                expandedMenu
                    .matchedGeometryEffect(id: "menuBackground", in: menuNamespace)
                    .transition(.identity)
            } else {
                collapsedHeader
                    .matchedGeometryEffect(id: "menuBackground", in: menuNamespace)
                    .transition(.identity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private var collapsedHeader: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.showListView.toggle()
            } label: {
                Image(systemName: viewModel.showListView ? "map" : "list.bullet")
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .contentTransition(.symbolEffect(.replace))
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
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
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .adaptiveGlassInteractive(in: .capsule)

            Spacer()

            Button {} label: {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: Theme.IconSize.medium, weight: .semibold))
                    .frame(width: 44, height: 44)
            }
        }
    }

    private var expandedMenu: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    closeMenu()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

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

                Spacer()

                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 4)

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
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            showLocationMenu = false
        }
    }
}

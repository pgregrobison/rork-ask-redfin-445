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
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showLocationMenu = false
                        }
                    }

                locationMenuPanel
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
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
                locationPill
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

    private var locationPill: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showLocationMenu.toggle()
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
    }

    private var locationMenuPanel: some View {
        LocationMenuView(
            viewModel: viewModel,
            searchService: locationSearchService,
            onClose: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    showLocationMenu = false
                }
            },
            onOpenFilter: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    showLocationMenu = false
                }
                showFilterSheet = true
            }
        )
        .adaptiveGlass(in: .rect(cornerRadius: 16))
    }
}

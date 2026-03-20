import SwiftUI
import MapKit

struct FindMapView: View {
    @Bindable var viewModel: ListingsViewModel
    let onListingTap: (Listing) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $viewModel.mapPosition) {
                ForEach(viewModel.listings) { listing in
                    Annotation(listing.id, coordinate: listing.coordinate) {
                        Button {
                            viewModel.selectListing(listing)
                        } label: {
                            MapPinView(
                                listing: listing,
                                isSelected: viewModel.selectedListing?.id == listing.id,
                                isSeen: viewModel.isSeen(listing)
                            )
                        }
                    }
                    .annotationTitles(.hidden)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.persistMapRegion(context.region)
                viewModel.updateLocationName(for: context.region)
            }
            .ignoresSafeArea()
            .onTapGesture {
                if viewModel.selectedListing != nil {
                    viewModel.dismissOverlay()
                }
            }
            .overlay(alignment: .topTrailing) {
                GlassActionButtonStack(items: [
                    GlassActionButtonItem(icon: "square.3.layers.3d", action: {}),
                    GlassActionButtonItem(icon: "hand.draw", action: {}),
                    GlassActionButtonItem(icon: viewModel.locationService.isTrackingUser ? "location.fill" : "location", action: {
                        viewModel.locateUser()
                    })
                ])
                .padding(.trailing, 16)
                .padding(.top, 4)
            }

            if let listing = viewModel.selectedListing {
                ListingCardOverlay(
                    listing: listing,
                    isSaved: viewModel.isSaved(listing),
                    onDismiss: { viewModel.dismissOverlay() },
                    onToggleSave: { viewModel.toggleSaved(listing) },
                    onTap: { onListingTap(listing) }
                )
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.selectedListing?.id)
            }
        }
        .onChange(of: viewModel.locationService.userLocation?.coordinate.latitude) { _, _ in
            if viewModel.locationService.isTrackingUser {
                viewModel.panToUserLocation()
            }
        }
    }
}

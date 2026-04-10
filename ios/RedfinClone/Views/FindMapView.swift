import SwiftUI
import MapKit

struct FindMapView: View {
    @Bindable var viewModel: ListingsViewModel
    var zoomNamespace: Namespace.ID
    let onListingTap: (Listing) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $viewModel.mapPosition) {
                ForEach(viewModel.filteredListings) { listing in
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

                if let userCoord = viewModel.locationService.userLocation?.coordinate {
                    Annotation("My Location", coordinate: userCoord) {
                        UserLocationDot()
                    }
                    .annotationTitles(.hidden)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls { }
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.persistMapRegion(context.region)
                viewModel.updateLocationName(for: context.region)
            }
            .ignoresSafeArea()

            .overlay(alignment: .topTrailing) {
                MapActionButtons(viewModel: viewModel)
            }


            Group {
                if let listing = viewModel.selectedListing {
                    ListingCardOverlay(
                        listing: listing,
                        isSaved: viewModel.isSaved(listing),
                        zoomNamespace: zoomNamespace,
                        onDismiss: { viewModel.dismissOverlay() },
                        onToggleSave: { viewModel.toggleSaved(listing) },
                        onTap: { onListingTap(listing) }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(viewModel.debugSettings?.overlayAnimation ?? .spring(response: 0.35, dampingFraction: 0.8), value: viewModel.selectedListing?.id)
        }
        .onChange(of: viewModel.locationService.userLocation?.coordinate.latitude) { _, _ in
            if viewModel.locationService.isTrackingUser {
                viewModel.panToUserLocation()
                viewModel.triggerCompassNotificationIfNeeded()
            }
        }
    }
}

private struct MapActionButtons: View {
    let viewModel: ListingsViewModel

    var body: some View {
        GlassActionButtonStack(items: [
            GlassActionButtonItem(icon: "square.3.layers.3d", action: {}),
            GlassActionButtonItem(icon: "hand.draw", action: {}),
            GlassActionButtonItem(icon: viewModel.locationService.isTrackingUser ? "location.fill" : "location", action: {
                viewModel.locateUser()
            })
        ])
        .padding(.trailing, Theme.Spacing.md)
        .padding(.top, Theme.Spacing.xs)
        .animation(nil, value: viewModel.selectedListing != nil)
    }
}

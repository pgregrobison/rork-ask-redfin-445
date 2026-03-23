import Foundation
import SwiftUI
import MapKit
import CoreLocation

nonisolated enum SortOption: String, CaseIterable, Sendable {
    case recommended = "Recommended"
    case priceLowToHigh = "Price Low→High"
    case priceHighToLow = "Price High→Low"
    case newest = "Newest"
    case sqft = "Sq Ft"
}

@Observable
@MainActor
class ListingsViewModel {
    var listings: [Listing] = MockData.listings
    var savedListingIDs: Set<String> = []
    var seenListingIDs: Set<String> = []
    var selectedListing: Listing?
    var sortOption: SortOption = .recommended
    var showListView: Bool = false
    var showChat: Bool = false
    var locationName: String = "New York City"
    private var geocodeTask: Task<Void, Never>?
    private let geocoder = CLGeocoder()
    let locationService = LocationService()
    private var currentSpan = MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    var mapPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    ))

    var sortedListings: [Listing] {
        switch sortOption {
        case .recommended:
            return listings.sorted { a, b in
                if a.isHotHome != b.isHotHome { return a.isHotHome }
                return a.daysOnMarket < b.daysOnMarket
            }
        case .priceLowToHigh:
            return listings.sorted { $0.price < $1.price }
        case .priceHighToLow:
            return listings.sorted { $0.price > $1.price }
        case .newest:
            return listings.sorted { $0.daysOnMarket < $1.daysOnMarket }
        case .sqft:
            return listings.sorted { $0.sqft > $1.sqft }
        }
    }

    var hotHomes: [Listing] {
        listings.filter { $0.isHotHome }
    }

    var justListed: [Listing] {
        listings.filter { $0.daysOnMarket <= 14 }.sorted { $0.daysOnMarket < $1.daysOnMarket }
    }

    var savedListings: [Listing] {
        listings.filter { savedListingIDs.contains($0.id) }
    }

    init() {
        loadSavedListings()
    }

    func toggleSaved(_ listing: Listing) {
        if savedListingIDs.contains(listing.id) {
            savedListingIDs.remove(listing.id)
        } else {
            savedListingIDs.insert(listing.id)
        }
        persistSavedListings()
    }

    func isSaved(_ listing: Listing) -> Bool {
        savedListingIDs.contains(listing.id)
    }

    func markSeen(_ listing: Listing) {
        seenListingIDs.insert(listing.id)
    }

    func isSeen(_ listing: Listing) -> Bool {
        seenListingIDs.contains(listing.id)
    }

    func selectListing(_ listing: Listing) {
        if selectedListing?.id == listing.id {
            dismissOverlay()
            return
        }
        selectedListing = listing
        markSeen(listing)
        withAnimation(.easeOut(duration: 0.25)) {
            mapPosition = .region(MKCoordinateRegion(
                center: listing.coordinate,
                span: currentSpan
            ))
        }
    }

    func dismissOverlay() {
        selectedListing = nil
    }

    func persistMapRegion(_ region: MKCoordinateRegion) {
        currentSpan = region.span
        mapPosition = .region(region)
        locationService.isTrackingUser = false
    }

    func locateUser() {
        locationService.locateUser()
    }

    func panToUserLocation() {
        guard let location = locationService.userLocation else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            mapPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }

    func updateLocationName(for region: MKCoordinateRegion) {
        geocodeTask?.cancel()
        geocodeTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                guard !Task.isCancelled else { return }
                if let placemark = placemarks.first {
                    let name = placemark.subLocality
                        ?? placemark.locality
                        ?? placemark.administrativeArea
                        ?? "New York City"
                    locationName = name
                }
            } catch {
                guard !Task.isCancelled else { return }
                if let nearest = nearestListing(to: region.center) {
                    locationName = nearest.city
                }
            }
        }
    }

    private func nearestListing(to center: CLLocationCoordinate2D) -> Listing? {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return listings.min { a, b in
            let distA = CLLocation(latitude: a.latitude, longitude: a.longitude).distance(from: centerLocation)
            let distB = CLLocation(latitude: b.latitude, longitude: b.longitude).distance(from: centerLocation)
            return distA < distB
        }
    }

    private func persistSavedListings() {
        let array = Array(savedListingIDs)
        UserDefaults.standard.set(array, forKey: "savedListingIDs")
    }

    private func loadSavedListings() {
        if let array = UserDefaults.standard.stringArray(forKey: "savedListingIDs") {
            savedListingIDs = Set(array)
        }
    }
}

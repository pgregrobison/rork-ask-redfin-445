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
    let notificationService = NotificationService()
    private var currentSpan = MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    private var isPanning: Bool = false
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
        panToListing(listing)
    }

    func fitListings(_ listings: [Listing]) {
        guard !listings.isEmpty else { return }
        if listings.count == 1, let only = listings.first {
            panToListing(only)
            return
        }
        var minLat = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var minLon = Double.greatestFiniteMagnitude
        var maxLon = -Double.greatestFiniteMagnitude
        for listing in listings {
            let coord = listing.coordinate
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }
        let padding = 1.3
        let latDelta = max((maxLat - minLat) * padding, 0.01)
        let lonDelta = max((maxLon - minLon) * padding, 0.01)
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        isPanning = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            mapPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
        currentSpan = span
        Task {
            try? await Task.sleep(for: .milliseconds(550))
            isPanning = false
        }
    }

    func panToListing(_ listing: Listing) {
        isPanning = true
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            mapPosition = .region(MKCoordinateRegion(
                center: listing.coordinate,
                span: currentSpan
            ))
        }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            isPanning = false
        }
    }

    func dismissOverlay() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedListing = nil
        }
    }

    func persistMapRegion(_ region: MKCoordinateRegion) {
        currentSpan = region.span
        guard !isPanning else { return }
        mapPosition = .region(region)
        locationService.isTrackingUser = false
    }

    var compassListings: [Listing] {
        listings.filter { $0.isCompassComingSoon }
    }

    func locateUser() {
        locationService.locateUser()
    }

    func triggerCompassNotificationIfNeeded() {
        guard let userLocation = locationService.userLocation else { return }
        let nearest = compassListings
            .map { (listing: $0, dist: CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: userLocation)) }
            .min { $0.dist < $1.dist }
        if let nearest {
            notificationService.scheduleCompassNotification(nearestListing: nearest.listing)
        }
    }

    func selectNearestCompassListing(to location: CLLocation?) {
        let ref = location ?? locationService.userLocation
        guard let ref else { return }
        let nearest = compassListings
            .map { (listing: $0, dist: CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: ref)) }
            .min { $0.dist < $1.dist }
        if let nearest {
            selectedListing = nearest.listing
            markSeen(nearest.listing)
            fitUserAndListing(nearest.listing)
        }
    }

    private func fitUserAndListing(_ listing: Listing) {
        guard let userCoord = locationService.userLocation?.coordinate else {
            panToListing(listing)
            return
        }
        let listingCoord = listing.coordinate
        let minLat = min(userCoord.latitude, listingCoord.latitude)
        let maxLat = max(userCoord.latitude, listingCoord.latitude)
        let minLon = min(userCoord.longitude, listingCoord.longitude)
        let maxLon = max(userCoord.longitude, listingCoord.longitude)
        let padding = 1.6
        let latDelta = max((maxLat - minLat) * padding, 0.01)
        let lonDelta = max((maxLon - minLon) * padding, 0.01)
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        isPanning = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            mapPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
        currentSpan = span
        Task {
            try? await Task.sleep(for: .milliseconds(550))
            isPanning = false
        }
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

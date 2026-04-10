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
    var debugSettings: DebugSettings?
    var listings: [Listing] = MockData.listings
    var savedListingIDs: Set<String> = []
    var seenListingIDs: Set<String> = []
    var selectedListing: Listing?
    var sortOption: SortOption = .recommended
    var showListView: Bool = false
    var showChat: Bool = false
    var locationName: String = "New York City"

    var filterMinPrice: Int? = nil
    var filterMaxPrice: Int? = nil
    var filterMinBeds: Int = 0
    var filterMinBaths: Int = 0
    private var geocodeTask: Task<Void, Never>?
    private let geocoder = CLGeocoder()
    let locationService = LocationService()
    let notificationService = NotificationService()
    private var currentSpan = MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    private var currentCenter = CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855)
    private var isAnimatingCamera: Bool = false
    private var cameraAnimationTask: Task<Void, Never>?
    var mapPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    ))

    var filteredListings: [Listing] {
        var result = listings
        if let minPrice = filterMinPrice {
            result = result.filter { $0.price >= minPrice }
        }
        if let maxPrice = filterMaxPrice {
            result = result.filter { $0.price <= maxPrice }
        }
        if filterMinBeds > 0 {
            result = result.filter { $0.beds >= filterMinBeds }
        }
        if filterMinBaths > 0 {
            result = result.filter { Int($0.baths) >= filterMinBaths }
        }
        return result
    }

    var sortedListings: [Listing] {
        let base = filteredListings
        switch sortOption {
        case .recommended:
            return base.sorted { a, b in
                if a.isHotHome != b.isHotHome { return a.isHotHome }
                return a.daysOnMarket < b.daysOnMarket
            }
        case .priceLowToHigh:
            return base.sorted { $0.price < $1.price }
        case .priceHighToLow:
            return base.sorted { $0.price > $1.price }
        case .newest:
            return base.sorted { $0.daysOnMarket < $1.daysOnMarket }
        case .sqft:
            return base.sorted { $0.sqft > $1.sqft }
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

    private let headerFraction: CGFloat = 0.12

    func fitListings(_ listings: [Listing], sheetFraction: CGFloat = 0) {
        guard !listings.isEmpty else { return }
        if listings.count == 1, let only = listings.first {
            panToListing(only, sheetFraction: sheetFraction)
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
        let pinLatDelta = max((maxLat - minLat) * padding, 0.01)
        let lonDelta = max((maxLon - minLon) * padding, 0.01)
        let pinCenterLat = (minLat + maxLat) / 2
        let pinCenterLon = (minLon + maxLon) / 2

        let totalOccluded = sheetFraction + headerFraction
        let visibleFraction = max(1.0 - totalOccluded, 0.15)
        let latDelta = pinLatDelta / visibleFraction
        let bottomOffset = sheetFraction / 2.0 * latDelta
        let topOffset = headerFraction / 2.0 * latDelta
        let centerLat = pinCenterLat - bottomOffset + topOffset

        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: pinCenterLon)
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        isAnimatingCamera = true
        withAnimation(.easeInOut(duration: 0.5)) {
            mapPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
        currentSpan = span
        Task {
            try? await Task.sleep(for: .milliseconds(550))
            isAnimatingCamera = false
        }
    }

    private let cardOverlayFraction: CGFloat = 0.30

    func panToListing(_ listing: Listing, sheetFraction: CGFloat = 0) {
        let coord = listing.coordinate
        let spanLat = currentSpan.latitudeDelta
        let adjustedLat: Double
        if sheetFraction > 0 {
            let bottomOffset = sheetFraction / 2.0 * spanLat
            let topOffset = headerFraction / 2.0 * spanLat
            adjustedLat = coord.latitude - bottomOffset + topOffset
        } else {
            let cardOffset = cardOverlayFraction / 2.0 * spanLat
            adjustedLat = coord.latitude - cardOffset
        }
        let targetRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: adjustedLat, longitude: coord.longitude),
            span: currentSpan
        )
        let startRegion = MKCoordinateRegion(center: currentCenter, span: currentSpan)
        let settings = debugSettings
        let useSpring = settings?.panUseSpring ?? false
        if useSpring {
            animateCameraSpring(
                from: startRegion, to: targetRegion,
                response: settings?.panSpringResponse ?? 0.35,
                damping: settings?.panSpringDamping ?? 0.8
            )
        } else {
            animateCameraEaseInOut(
                from: startRegion, to: targetRegion,
                duration: settings?.panDuration ?? 0.35
            )
        }
    }

    func dismissOverlay() {
        let anim = debugSettings?.dismissAnimation ?? .spring(response: 0.35, dampingFraction: 0.8)
        withAnimation(anim) {
            selectedListing = nil
        }
    }

    func persistMapRegion(_ region: MKCoordinateRegion) {
        if !isAnimatingCamera {
            currentSpan = region.span
            currentCenter = region.center
        }
        locationService.isTrackingUser = false
    }

    private func animateCameraEaseInOut(from startRegion: MKCoordinateRegion, to endRegion: MKCoordinateRegion, duration: Double) {
        cameraAnimationTask?.cancel()
        isAnimatingCamera = true
        let steps = max(Int(duration * 60), 2)
        let sleepNano = UInt64(duration / Double(steps) * 1_000_000_000)

        cameraAnimationTask = Task {
            for i in 1...steps {
                guard !Task.isCancelled else { break }
                let t = Double(i) / Double(steps)
                let eased = t < 0.5 ? 2.0 * t * t : 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0
                mapPosition = .region(interpolateRegion(from: startRegion, to: endRegion, t: eased))
                try? await Task.sleep(nanoseconds: sleepNano)
            }
            mapPosition = .region(endRegion)
            currentCenter = endRegion.center
            currentSpan = endRegion.span
            isAnimatingCamera = false
        }
    }

    private func animateCameraSpring(from startRegion: MKCoordinateRegion, to endRegion: MKCoordinateRegion, response: Double, damping: Double) {
        cameraAnimationTask?.cancel()
        isAnimatingCamera = true

        var positions = [startRegion.center.latitude, startRegion.center.longitude,
                         startRegion.span.latitudeDelta, startRegion.span.longitudeDelta]
        let targets = [endRegion.center.latitude, endRegion.center.longitude,
                       endRegion.span.latitudeDelta, endRegion.span.longitudeDelta]
        var velocities = [0.0, 0.0, 0.0, 0.0]
        let omega = 2.0 * .pi / response

        cameraAnimationTask = Task {
            let dt = 1.0 / 60.0
            var totalTime = 0.0
            let maxTime = max(response * 6.0, 1.5)

            while !Task.isCancelled && totalTime < maxTime {
                var settled = true
                for i in 0..<4 {
                    let accel = omega * omega * (targets[i] - positions[i]) - 2.0 * damping * omega * velocities[i]
                    velocities[i] += accel * dt
                    positions[i] += velocities[i] * dt
                    let range = abs(targets[i] - [startRegion.center.latitude, startRegion.center.longitude,
                                                   startRegion.span.latitudeDelta, startRegion.span.longitudeDelta][i])
                    let threshold = max(range * 0.002, 0.00001)
                    if abs(positions[i] - targets[i]) > threshold || abs(velocities[i]) > threshold * 5 {
                        settled = false
                    }
                }

                mapPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: positions[0], longitude: positions[1]),
                    span: MKCoordinateSpan(latitudeDelta: max(positions[2], 0.001), longitudeDelta: max(positions[3], 0.001))
                ))

                totalTime += dt
                if settled { break }
                try? await Task.sleep(nanoseconds: 16_000_000)
            }

            mapPosition = .region(endRegion)
            currentCenter = endRegion.center
            currentSpan = endRegion.span
            isAnimatingCamera = false
        }
    }

    private func interpolateRegion(from: MKCoordinateRegion, to: MKCoordinateRegion, t: Double) -> MKCoordinateRegion {
        let lat = from.center.latitude + (to.center.latitude - from.center.latitude) * t
        let lon = from.center.longitude + (to.center.longitude - from.center.longitude) * t
        let latD = from.span.latitudeDelta + (to.span.latitudeDelta - from.span.latitudeDelta) * t
        let lonD = from.span.longitudeDelta + (to.span.longitudeDelta - from.span.longitudeDelta) * t
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: max(latD, 0.001), longitudeDelta: max(lonD, 0.001))
        )
    }

    var compassListings: [Listing] {
        listings.filter { $0.isCompassComingSoon }
    }

    func locateUser() {
        locationService.locateUser()
        if locationService.userLocation != nil {
            panToUserLocation()
        }
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

    func fitUserAndListing(_ listing: Listing) {
        guard let userCoord = locationService.userLocation?.coordinate else {
            panToListing(listing)
            return
        }
        let listingCoord = listing.coordinate
        let minLat = min(userCoord.latitude, listingCoord.latitude)
        let maxLat = max(userCoord.latitude, listingCoord.latitude)
        let minLon = min(userCoord.longitude, listingCoord.longitude)
        let maxLon = max(userCoord.longitude, listingCoord.longitude)
        let padding = 1.05
        let latDelta = max((maxLat - minLat) * padding, 0.004)
        let lonDelta = max((maxLon - minLon) * padding, 0.004)
        let cardOffsetRatio = 0.2
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2 - latDelta * cardOffsetRatio,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        isAnimatingCamera = true
        withAnimation(.easeInOut(duration: 1.0)) {
            mapPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
        currentSpan = span
        Task {
            try? await Task.sleep(for: .milliseconds(1100))
            isAnimatingCamera = false
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

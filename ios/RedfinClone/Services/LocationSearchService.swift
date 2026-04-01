import Foundation
import MapKit

@Observable
class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate {
    var searchText: String = ""
    var suggestions: [MKLocalSearchCompletion] = []
    var isSearching: Bool = false

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest, .query]
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        )
    }

    func updateQuery(_ query: String) {
        searchText = query
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            suggestions = []
            isSearching = false
            return
        }
        isSearching = true
        completer.queryFragment = query
    }

    func clear() {
        searchText = ""
        suggestions = []
        isSearching = false
    }

    func search(for completion: MKLocalSearchCompletion) async -> MKCoordinateRegion? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            return response.boundingRegion
        } catch {
            return nil
        }
    }

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            suggestions = Array(completer.results.prefix(6))
            isSearching = false
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            isSearching = false
        }
    }
}

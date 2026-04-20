import Foundation
import MapKit

nonisolated enum NeighborhoodBounds {
    static let table: [(keys: [String], region: MKCoordinateRegion)] = [
        (["upper west side", "upper west", "uws"], region(40.7870, -73.9754, 0.025, 0.018)),
        (["upper east side", "upper east", "ues"], region(40.7736, -73.9566, 0.025, 0.018)),
        (["tribeca"], region(40.7195, -74.0089, 0.012, 0.012)),
        (["soho"], region(40.7233, -74.0020, 0.012, 0.012)),
        (["west village"], region(40.7359, -74.0036, 0.014, 0.014)),
        (["east village"], region(40.7265, -73.9815, 0.014, 0.014)),
        (["hudson yards"], region(40.7539, -74.0013, 0.010, 0.010)),
        (["hell's kitchen", "hells kitchen"], region(40.7638, -73.9918, 0.015, 0.014)),
        (["murray hill"], region(40.7479, -73.9784, 0.014, 0.014)),
        (["financial district", "fidi"], region(40.7075, -74.0100, 0.014, 0.014)),
        (["midtown"], region(40.7549, -73.9840, 0.022, 0.022)),
        (["chelsea"], region(40.7465, -74.0014, 0.016, 0.014)),
        (["harlem"], region(40.8116, -73.9465, 0.025, 0.022)),
        (["brooklyn"], region(40.6782, -73.9442, 0.12, 0.12)),
        (["williamsburg"], region(40.7081, -73.9571, 0.022, 0.022)),
        (["bushwick"], region(40.6958, -73.9171, 0.022, 0.022)),
        (["park slope"], region(40.6710, -73.9814, 0.018, 0.018)),
        (["dumbo"], region(40.7033, -73.9881, 0.010, 0.010)),
        (["queens"], region(40.7282, -73.7949, 0.12, 0.14)),
        (["long island city", "lic"], region(40.7447, -73.9485, 0.020, 0.020)),
        (["astoria"], region(40.7644, -73.9235, 0.022, 0.022)),
        (["manhattan"], region(40.7831, -73.9712, 0.11, 0.08)),
        (["eastlake"], region(47.6380, -122.3270, 0.020, 0.020)),
        (["seattle"], region(47.6062, -122.3321, 0.14, 0.14))
    ]

    static func region(for name: String) -> MKCoordinateRegion? {
        let lower = name.lowercased()
        for entry in table {
            if entry.keys.contains(where: { lower == $0 || lower.contains($0) }) {
                return entry.region
            }
        }
        return nil
    }

    private static func region(_ lat: Double, _ lon: Double, _ latD: Double, _ lonD: Double) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: latD, longitudeDelta: lonD)
        )
    }
}

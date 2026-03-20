import SwiftUI
import MapKit

nonisolated struct TourStop: Identifiable, Sendable {
    let id: Int
    let address: String
    let coordinate: CLLocationCoordinate2D
}

struct TourRouteMapWidget: View {
    private let tourStops: [TourStop] = [
        TourStop(id: 1, address: "320 E 57th St, Manhattan", coordinate: CLLocationCoordinate2D(latitude: 40.7590, longitude: -73.9640)),
        TourStop(id: 2, address: "145 Hudson St, Tribeca", coordinate: CLLocationCoordinate2D(latitude: 40.7200, longitude: -74.0080)),
        TourStop(id: 3, address: "87 Montague St, Brooklyn Heights", coordinate: CLLocationCoordinate2D(latitude: 40.6940, longitude: -73.9930))
    ]

    @State private var mapPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7280, longitude: -73.9850),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "map")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tour Route")
                        .font(.headline)
                    Text("\(tourStops.count) stops planned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)

            Map(position: $mapPosition) {
                ForEach(tourStops) { stop in
                    Annotation(stop.address, coordinate: stop.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.15))
                                .frame(width: 28, height: 28)
                            Text("\(stop.id)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .annotationTitles(.hidden)
                }

                MapPolyline(coordinates: tourStops.map { $0.coordinate })
                    .stroke(Color(white: 0.15), lineWidth: 3)
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .frame(height: 200)
            .allowsHitTesting(false)

            VStack(spacing: 8) {
                ForEach(tourStops) { stop in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.15))
                                .frame(width: 22, height: 22)
                            Text("\(stop.id)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        Text(stop.address)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 16)
    }
}

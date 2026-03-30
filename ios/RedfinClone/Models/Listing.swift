import Foundation
import CoreLocation

nonisolated struct Listing: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let price: Int
    let address: String
    let city: String
    let state: String
    let zip: String
    let beds: Int
    let baths: Double
    let sqft: Int
    let latitude: Double
    let longitude: Double
    let photos: [String]
    let description: String
    let yearBuilt: Int
    let lotSize: String
    let propertyType: String
    let isHotHome: Bool
    let tags: [String]
    let daysOnMarket: Int
    let hoaDues: String
    let buyerAgentFee: String
    var isListedByRedfin: Bool = false
    var isCompassComingSoon: Bool = false

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var fullAddress: String {
        "\(address), \(city), \(state) \(zip)"
    }

    var formattedPrice: String {
        if price >= 1_000_000 {
            let millions = Double(price) / 1_000_000.0
            if millions == Double(Int(millions)) {
                return "$\(Int(millions))M"
            }
            return "$\(String(format: "%.2g", millions))M"
        } else {
            let thousands = price / 1000
            return "$\(thousands)K"
        }
    }

    var formattedFullPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }

    var pricePerSqFt: Int {
        guard sqft > 0 else { return 0 }
        return price / sqft
    }

    var bathsFormatted: String {
        if baths == Double(Int(baths)) {
            return "\(Int(baths))"
        }
        return "\(baths)"
    }

    var viewsCount: Int {
        Int.random(in: 200...800)
    }

    var favoritesCount: Int {
        Int.random(in: 5...30)
    }

    var shareText: String {
        "\(fullAddress) - \(formattedFullPrice)"
    }

    var primaryBadge: HomeCardBadge? {
        if daysOnMarket > 0 && daysOnMarket <= 14 {
            return .daysAgo(daysOnMarket)
        } else if isHotHome {
            return .hot
        } else if isCompassComingSoon {
            return .compassComingSoon
        } else if isListedByRedfin {
            return .listedByRedfin
        }
        return nil
    }
}

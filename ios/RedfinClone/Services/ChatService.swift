import Foundation

nonisolated enum DemoResponseType: Sendable {
    case listings(text: String, filters: SearchFilters)
    case tour(text: String, request: TourRequest)
    case fallback(text: String)
}

@MainActor
class ChatService {

    func matchResponse(for input: String) -> DemoResponseType {
        let lower = input.lowercased()

        if lower.containsAny(["home", "house", "apartment", "condo", "listing", "find", "search", "property", "place", "buy"]) {
            let filters = extractFilters(from: lower)
            let text = buildListingsResponse(from: lower, filters: filters)
            return .listings(text: text, filters: filters)
        }

        if lower.containsAny(["tour", "schedule a tour", "tour a home", "tour this", "visit", "showing", "see the"]) {
            let address = extractAddress(from: lower)
            let listingId = extractListingId(from: lower)
            let text: String
            if let address {
                text = "Let's get you scheduled for a tour of \(address)! Pick a day and time that works for you."
            } else {
                text = "Let's get you scheduled! Pick a day and time that works for you."
            }
            let request = TourRequest(listingId: listingId, address: address)
            return .tour(text: text, request: request)
        }

        let fallbacks = [
            "I can help you find homes or schedule tours in the NYC area. Try asking me something like \"show me homes in Brooklyn\" or \"find condos under $1M\"!",
            "I'm your NYC real estate assistant! Ask me to find homes, apartments, or condos — or I can help schedule a tour. What are you looking for?",
            "Looking for your next home? I can search listings across Manhattan, Brooklyn, Queens, and more. Just tell me what you're looking for!"
        ]
        return .fallback(text: fallbacks.randomElement()!)
    }

    nonisolated func searchListings(filters: SearchFilters) -> [Listing] {
        var results = MockData.listings

        if let minBeds = filters.minBeds { results = results.filter { $0.beds >= minBeds } }
        if let maxBeds = filters.maxBeds { results = results.filter { $0.beds <= maxBeds } }
        if let minBaths = filters.minBaths { results = results.filter { $0.baths >= minBaths } }
        if let maxBaths = filters.maxBaths { results = results.filter { $0.baths <= maxBaths } }
        if let minPrice = filters.minPrice { results = results.filter { $0.price >= minPrice } }
        if let maxPrice = filters.maxPrice { results = results.filter { $0.price <= maxPrice } }
        if let minSqft = filters.minSqft { results = results.filter { $0.sqft >= minSqft } }
        if let maxSqft = filters.maxSqft { results = results.filter { $0.sqft <= maxSqft } }
        if let propertyType = filters.propertyType { results = results.filter { $0.propertyType.lowercased() == propertyType.lowercased() } }
        if let isHotHome = filters.isHotHome, isHotHome { results = results.filter { $0.isHotHome } }
        if let neighborhoods = filters.neighborhoods, !neighborhoods.isEmpty {
            let lower = neighborhoods.map { $0.lowercased() }
            results = results.filter { listing in
                lower.contains(where: { listing.city.lowercased().contains($0) })
            }
        }

        return results
    }

    private func extractFilters(from input: String) -> SearchFilters {
        var filters = SearchFilters()

        let bedroomPatterns: [(String, Int)] = [
            ("studio", 0), ("1 bed", 1), ("1 br", 1), ("one bed", 1), ("2 bed", 2), ("2 br", 2),
            ("two bed", 2), ("3 bed", 3), ("3 br", 3), ("three bed", 3), ("4 bed", 4), ("4 br", 4)
        ]
        for (pattern, beds) in bedroomPatterns {
            if input.contains(pattern) {
                filters.minBeds = beds
                break
            }
        }

        if input.contains("under 1m") || input.contains("under $1m") || input.contains("below 1m") {
            filters.maxPrice = 1_000_000
        } else if input.contains("under 2m") || input.contains("under $2m") || input.contains("below 2m") {
            filters.maxPrice = 2_000_000
        } else if input.contains("under 500") || input.contains("under $500") {
            filters.maxPrice = 500_000
        }

        if input.contains("condo") { filters.propertyType = "Condo" }
        else if input.contains("townhouse") { filters.propertyType = "Townhouse" }
        else if input.contains("co-op") || input.contains("coop") { filters.propertyType = "Co-op" }

        if input.containsAny(["hot home", "hot listing", "trending", "popular"]) {
            filters.isHotHome = true
        }

        let neighborhoods: [(String, String)] = [
            ("manhattan", "Manhattan"), ("brooklyn", "Brooklyn"), ("queens", "Queens"),
            ("lic", "Long Island City"), ("long island city", "Long Island City"),
            ("astoria", "Astoria"), ("williamsburg", "Williamsburg"),
            ("upper west", "Upper West Side"), ("upper east", "Upper East Side"),
            ("tribeca", "Tribeca"), ("soho", "SoHo")
        ]
        var matched: [String] = []
        for (keyword, name) in neighborhoods {
            if input.contains(keyword) { matched.append(name) }
        }
        if !matched.isEmpty { filters.neighborhoods = matched }

        return filters
    }

    private func extractAddress(from input: String) -> String? {
        for listing in MockData.listings {
            if input.contains(listing.address.lowercased()) || input.contains(listing.city.lowercased()) {
                return listing.address
            }
        }
        return nil
    }

    private func extractListingId(from input: String) -> String? {
        for listing in MockData.listings {
            if input.contains(listing.address.lowercased()) || input.contains(listing.city.lowercased()) {
                return listing.id
            }
        }
        return nil
    }

    private func buildListingsResponse(from input: String, filters: SearchFilters) -> String {
        let results = searchListings(filters: filters)
        if results.isEmpty {
            return "I couldn't find any listings matching those criteria. Try broadening your search — for example, ask me to show all homes in NYC."
        }

        var parts: [String] = []
        if let beds = filters.minBeds { parts.append(beds == 0 ? "studios" : "\(beds)+ bedroom") }
        if let type = filters.propertyType { parts.append(type.lowercased() + "s") }
        if let neighborhoods = filters.neighborhoods { parts.append("in \(neighborhoods.joined(separator: " & "))") }
        if let maxPrice = filters.maxPrice {
            let fmt = maxPrice >= 1_000_000 ? "$\(maxPrice / 1_000_000)M" : "$\(maxPrice / 1000)K"
            parts.append("under \(fmt)")
        }
        if filters.isHotHome == true { parts.append("that are trending") }

        let count = results.count
        if parts.isEmpty {
            return "I found \(count) home\(count == 1 ? "" : "s") in NYC. Here's what's available:"
        }
        return "I found \(count) \(parts.joined(separator: " ")) home\(count == 1 ? "" : "s"). Take a look:"
    }
}

private extension String {
    func containsAny(_ keywords: [String]) -> Bool {
        let lower = self.lowercased()
        return keywords.contains { lower.contains($0) }
    }
}

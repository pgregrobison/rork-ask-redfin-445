import Foundation

@MainActor
struct ToolExecutionResult {
    var resultJSON: String
    var searchFilters: SearchFilters?
    var searchResults: [Listing]?
    var addNeighborhoods: Bool = false
    var tourRequest: TourRequest?
    var mortgageRequest: MortgageRequest?
}

@MainActor
final class ToolExecutor {
    private let chatService: ChatService

    init(chatService: ChatService) {
        self.chatService = chatService
    }

    func execute(
        name: String,
        arguments: String,
        currentFindFilters: SearchFilters
    ) -> ToolExecutionResult {
        let args = parseArgs(arguments)
        switch name {
        case "search_homes":
            return runSearchHomes(args: args, currentFindFilters: currentFindFilters)
        case "schedule_tour":
            return runScheduleTour(args: args)
        case "prequalify":
            return runPrequalify(args: args)
        default:
            return ToolExecutionResult(resultJSON: "{\"error\":\"unknown_tool\"}")
        }
    }

    private func runSearchHomes(args: [String: Any], currentFindFilters: SearchFilters) -> ToolExecutionResult {
        var incoming = SearchFilters()
        if let v = args["min_beds"] as? Int { incoming.minBeds = v }
        else if let v = args["min_beds"] as? Double { incoming.minBeds = Int(v) }
        if let v = args["min_baths"] as? Double { incoming.minBaths = v }
        else if let v = args["min_baths"] as? Int { incoming.minBaths = Double(v) }
        if let v = args["max_price"] as? Int { incoming.maxPrice = v }
        else if let v = args["max_price"] as? Double { incoming.maxPrice = Int(v) }
        if let v = args["property_type"] as? String { incoming.propertyType = v }
        if let v = args["is_hot_home"] as? Bool { incoming.isHotHome = v }
        if let v = args["neighborhoods"] as? [String], !v.isEmpty { incoming.neighborhoods = v }

        let addNbhd = (args["add_neighborhoods"] as? Bool) ?? false

        let merged = chatService.mergeFilters(
            current: currentFindFilters,
            incoming: incoming,
            addNeighborhoods: addNbhd
        )
        let results = chatService.searchListings(filters: merged)

        var applied: [String: Any] = [:]
        if let v = merged.minBeds { applied["min_beds"] = v }
        if let v = merged.minBaths { applied["min_baths"] = v }
        if let v = merged.maxPrice { applied["max_price"] = v }
        if let v = merged.propertyType { applied["property_type"] = v }
        if let v = merged.neighborhoods { applied["neighborhoods"] = v }
        if let v = merged.isHotHome { applied["is_hot_home"] = v }

        let resultDict: [String: Any] = [
            "count": results.count,
            "listing_ids": results.prefix(10).map { $0.id },
            "applied_filters": applied
        ]
        let json = jsonString(from: resultDict)

        return ToolExecutionResult(
            resultJSON: json,
            searchFilters: merged,
            searchResults: results,
            addNeighborhoods: addNbhd
        )
    }

    private func runScheduleTour(args: [String: Any]) -> ToolExecutionResult {
        let address = args["address"] as? String
        let listingId = args["listing_id"] as? String
        let req = TourRequest(listingId: listingId, address: address)
        let json = jsonString(from: ["ok": true])
        return ToolExecutionResult(resultJSON: json, tourRequest: req)
    }

    private func runPrequalify(args: [String: Any]) -> ToolExecutionResult {
        let listingId = args["listing_id"] as? String
        let req = MortgageRequest(listingId: listingId)
        let json = jsonString(from: ["ok": true])
        return ToolExecutionResult(resultJSON: json, mortgageRequest: req)
    }

    private func parseArgs(_ raw: String) -> [String: Any] {
        guard let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return obj
    }

    private func jsonString(from obj: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: obj),
              let str = String(data: data, encoding: .utf8) else { return "{}" }
        return str
    }
}

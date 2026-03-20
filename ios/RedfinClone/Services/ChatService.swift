import Foundation

nonisolated struct StreamDelta: Sendable {
    let text: String?
    let toolCallId: String?
    let toolCallName: String?
    let toolCallArguments: String?
    let finishReason: String?
}

@MainActor
class ChatService {
    private var toolkitURL: String { Self.env("EXPO_PUBLIC_TOOLKIT_URL") }
    private var projectId: String { Self.env("EXPO_PUBLIC_PROJECT_ID") }
    private var teamId: String { Self.env("EXPO_PUBLIC_TEAM_ID") }
    private var appKey: String { Self.env("EXPO_PUBLIC_RORK_APP_KEY") }

    private static func env(_ key: String) -> String {
        if let v = ProcessInfo.processInfo.environment[key], !v.isEmpty {
            return v
        }
        if let v = Bundle.main.object(forInfoDictionaryKey: key) as? String,
           !v.isEmpty, !v.hasPrefix("$(") {
            return v
        }
        return ""
    }

    private let systemPrompt = """
    You are Ask Redfin, an AI-powered real estate assistant. You are professional, concise, and knowledgeable — like a top-performing real estate agent.

    You can answer general real estate questions about any market (market trends, buying tips, investment advice, neighborhood comparisons, etc.).

    For property searches, you have access to listings in the NYC metro area (Manhattan, Brooklyn, Queens, Long Island City, Astoria). When users ask to find homes, use the searchListings tool. When users want to schedule a tour, use the scheduleTour tool. When users ask about mortgage or prequalification, use the getMortgagePrequal tool.

    If a user asks to search for properties outside NYC, let them know your current listings cover the NYC metro area and offer to help them search there instead.

    Keep responses brief and direct. When you call searchListings, do not describe the individual results — the listing cards will appear automatically. Just acknowledge the search with a short sentence.
    """

    private func buildToolDefinitions() -> [String: Any] {
        [
            "searchListings": [
                "description": "Search for home listings in NYC. Use this when the user asks to find homes, apartments, condos, or any real estate properties.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "minBeds": ["type": "integer", "description": "Minimum number of bedrooms"],
                        "maxBeds": ["type": "integer", "description": "Maximum number of bedrooms"],
                        "minPrice": ["type": "integer", "description": "Minimum price in dollars"],
                        "maxPrice": ["type": "integer", "description": "Maximum price in dollars"],
                        "propertyType": ["type": "string", "description": "Property type filter", "enum": ["Condo", "Townhouse", "Co-op"]],
                        "isHotHome": ["type": "boolean", "description": "Only show hot homes"],
                        "neighborhoods": ["type": "array", "description": "Neighborhoods to search in", "items": ["type": "string"]]
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any],
            "scheduleTour": [
                "description": "Schedule a home tour for the user.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "listingId": ["type": "string", "description": "The listing ID"],
                        "address": ["type": "string", "description": "The address of the property"]
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any],
            "getMortgagePrequal": [
                "description": "Start a mortgage prequalification process.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "listingId": ["type": "string", "description": "Optional listing ID for context"]
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any]
        ]
    }

    private func buildMessages(from messages: [ChatMessage]) -> [[String: Any]] {
        var result: [[String: Any]] = [
            ["role": "system", "content": systemPrompt]
        ]

        for msg in messages {
            guard msg.role == .user || msg.role == .assistant else { continue }

            if msg.role == .user {
                result.append(["role": "user", "content": msg.content])
            } else {
                if msg.content.isEmpty && msg.toolCalls == nil { continue }

                var parts: [[String: Any]] = []

                if !msg.content.isEmpty {
                    parts.append(["type": "text", "text": msg.content])
                }

                if let toolCalls = msg.toolCalls, !toolCalls.isEmpty {
                    for tc in toolCalls {
                        var toolPart: [String: Any] = [
                            "type": "tool-invocation",
                            "toolInvocationId": tc.id,
                            "toolName": tc.name,
                            "state": "result"
                        ]
                        if let argsData = tc.arguments.data(using: .utf8),
                           let argsObj = try? JSONSerialization.jsonObject(with: argsData) {
                            toolPart["args"] = argsObj
                        } else {
                            toolPart["args"] = [String: Any]()
                        }
                        toolPart["result"] = tc.result ?? ""
                        parts.append(toolPart)
                    }
                }

                result.append(["role": "assistant", "content": parts])
            }
        }

        return result
    }

    func sendMessage(messages: [ChatMessage]) -> AsyncStream<StreamDelta> {
        let builtMessages = buildMessages(from: messages)
        let tools = buildToolDefinitions()
        let baseURL = toolkitURL
        let projId = projectId
        let tId = teamId
        let aKey = appKey

        let body: [String: Any] = [
            "messages": builtMessages,
            "tools": tools
        ]

        return AsyncStream { continuation in
            Task.detached { [baseURL, body, projId, tId, aKey] in
                do {
                    guard !baseURL.isEmpty else {
                        continuation.yield(StreamDelta(
                            text: "Configuration error — toolkit URL is not set. The app needs to be rebuilt with environment variables injected.",
                            toolCallId: nil, toolCallName: nil, toolCallArguments: nil, finishReason: "error"))
                        continuation.finish()
                        return
                    }

                    guard let endpoint = URL(string: "\(baseURL)/agent/chat") else {
                        continuation.yield(StreamDelta(
                            text: "Configuration error — invalid toolkit URL: \(baseURL)",
                            toolCallId: nil, toolCallName: nil, toolCallArguments: nil, finishReason: "error"))
                        continuation.finish()
                        return
                    }

                    var urlRequest = URLRequest(url: endpoint)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    if !projId.isEmpty { urlRequest.setValue(projId, forHTTPHeaderField: "x-project-id") }
                    if !tId.isEmpty { urlRequest.setValue(tId, forHTTPHeaderField: "x-team-id") }
                    if !aKey.isEmpty { urlRequest.setValue(aKey, forHTTPHeaderField: "x-app-key") }
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
                    urlRequest.timeoutInterval = 60

                    let (bytes, response) = try await URLSession.shared.bytes(for: urlRequest)

                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                        var errorDetail = "error \(statusCode)"
                        do {
                            var bodyData = Data()
                            for try await byte in bytes {
                                bodyData.append(byte)
                                if bodyData.count > 4096 { break }
                            }
                            if let errorBody = String(data: bodyData, encoding: .utf8), !errorBody.isEmpty {
                                errorDetail = "error \(statusCode): \(errorBody.prefix(500))"
                            }
                        } catch {}
                        continuation.yield(StreamDelta(
                            text: "I'm having trouble connecting (\(errorDetail)). Please try again.",
                            toolCallId: nil, toolCallName: nil, toolCallArguments: nil, finishReason: "error"))
                        continuation.finish()
                        return
                    }

                    var pendingToolInputs: [String: (name: String, argChunks: String)] = [:]

                    for try await line in bytes.lines {
                        if line.hasPrefix("data: ") {
                            let payload = String(line.dropFirst(6))

                            if payload == "[DONE]" {
                                for (toolId, tool) in pendingToolInputs {
                                    continuation.yield(StreamDelta(text: nil, toolCallId: toolId, toolCallName: tool.name, toolCallArguments: tool.argChunks, finishReason: "tool_calls"))
                                }
                                pendingToolInputs.removeAll()
                                continuation.yield(StreamDelta(text: nil, toolCallId: nil, toolCallName: nil, toolCallArguments: nil, finishReason: "stop"))
                                break
                            }

                            guard let data = payload.data(using: .utf8),
                                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }

                            let eventType = json["type"] as? String ?? ""

                            switch eventType {
                            case "text-delta":
                                if let delta = json["textDelta"] as? String {
                                    continuation.yield(StreamDelta(text: delta, toolCallId: nil, toolCallName: nil, toolCallArguments: nil, finishReason: nil))
                                } else if let delta = json["delta"] as? String {
                                    continuation.yield(StreamDelta(text: delta, toolCallId: nil, toolCallName: nil, toolCallArguments: nil, finishReason: nil))
                                }

                            case "tool-call":
                                let toolId = json["toolCallId"] as? String ?? UUID().uuidString
                                let toolName = json["toolName"] as? String ?? ""
                                let args: String
                                if let argsDict = json["args"] {
                                    if let argsData = try? JSONSerialization.data(withJSONObject: argsDict) {
                                        args = String(data: argsData, encoding: .utf8) ?? "{}"
                                    } else { args = "{}" }
                                } else {
                                    args = pendingToolInputs[toolId]?.argChunks ?? "{}"
                                }
                                pendingToolInputs.removeValue(forKey: toolId)
                                continuation.yield(StreamDelta(text: nil, toolCallId: toolId, toolCallName: toolName, toolCallArguments: args, finishReason: "tool_calls"))

                            case "tool-call-streaming-start":
                                if let toolCallId = json["toolCallId"] as? String,
                                   let toolName = json["toolName"] as? String {
                                    pendingToolInputs[toolCallId] = (name: toolName, argChunks: "")
                                }

                            case "tool-call-delta":
                                if let toolCallId = json["toolCallId"] as? String,
                                   let argsDelta = json["argsTextDelta"] as? String {
                                    pendingToolInputs[toolCallId]?.argChunks += argsDelta
                                }

                            case "tool-input-start":
                                if let toolCallId = json["toolCallId"] as? String,
                                   let toolName = json["toolName"] as? String {
                                    pendingToolInputs[toolCallId] = (name: toolName, argChunks: "")
                                }

                            case "tool-input-delta":
                                if let toolCallId = json["toolCallId"] as? String,
                                   let inputDelta = json["inputTextDelta"] as? String {
                                    pendingToolInputs[toolCallId]?.argChunks += inputDelta
                                }

                            case "tool-input-available":
                                if let toolCallId = json["toolCallId"] as? String,
                                   let toolName = json["toolName"] as? String {
                                    let args: String
                                    if let input = json["input"] {
                                        if let inputData = try? JSONSerialization.data(withJSONObject: input) {
                                            args = String(data: inputData, encoding: .utf8) ?? "{}"
                                        } else { args = "{}" }
                                    } else {
                                        args = pendingToolInputs[toolCallId]?.argChunks ?? "{}"
                                    }
                                    pendingToolInputs.removeValue(forKey: toolCallId)
                                    continuation.yield(StreamDelta(text: nil, toolCallId: toolCallId, toolCallName: toolName, toolCallArguments: args, finishReason: "tool_calls"))
                                }

                            case "start", "text-start", "text-end", "message-start", "message-finish",
                                 "step-start", "step-finish", "tool-output-available", "abort", "finish":
                                break

                            default:
                                break
                            }

                        } else if !line.isEmpty {
                            Self.parseNumberedLine(line, pendingToolInputs: &pendingToolInputs, continuation: continuation)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.yield(StreamDelta(
                        text: "Connection error: \(error.localizedDescription)",
                        toolCallId: nil, toolCallName: nil, toolCallArguments: nil, finishReason: "error"))
                    continuation.finish()
                }
            }
        }
    }

    private nonisolated static func parseNumberedLine(
        _ line: String,
        pendingToolInputs: inout [String: (name: String, argChunks: String)],
        continuation: AsyncStream<StreamDelta>.Continuation
    ) {
        guard let colonIndex = line.firstIndex(of: ":"),
              colonIndex != line.startIndex else { return }

        let prefix = String(line[line.startIndex..<colonIndex])
        let content = String(line[line.index(after: colonIndex)...])

        switch prefix {
        case "0":
            if let data = content.data(using: .utf8),
               let text = try? JSONSerialization.jsonObject(with: data) as? String {
                continuation.yield(StreamDelta(text: text, toolCallId: nil, toolCallName: nil, toolCallArguments: nil, finishReason: nil))
            }

        case "9":
            if let data = content.data(using: .utf8),
               let toolCall = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let toolId = toolCall["toolCallId"] as? String ?? UUID().uuidString
                let toolName = toolCall["toolName"] as? String ?? ""
                let args: String
                if let argsObj = toolCall["args"] {
                    if let argsData = try? JSONSerialization.data(withJSONObject: argsObj) {
                        args = String(data: argsData, encoding: .utf8) ?? "{}"
                    } else { args = "{}" }
                } else { args = "{}" }
                continuation.yield(StreamDelta(text: nil, toolCallId: toolId, toolCallName: toolName, toolCallArguments: args, finishReason: "tool_calls"))
            }

        case "b":
            if let data = content.data(using: .utf8),
               let toolStart = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let toolId = toolStart["toolCallId"] as? String ?? UUID().uuidString
                let toolName = toolStart["toolName"] as? String ?? ""
                pendingToolInputs[toolId] = (name: toolName, argChunks: "")
            }

        case "c":
            if let data = content.data(using: .utf8),
               let toolDelta = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let toolId = toolDelta["toolCallId"] as? String ?? ""
                let argsDelta = toolDelta["argsTextDelta"] as? String ?? ""
                pendingToolInputs[toolId]?.argChunks += argsDelta
            }

        case "a":
            if let data = content.data(using: .utf8),
               let toolResult = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let toolId = toolResult["toolCallId"] as? String ?? ""
                if let tool = pendingToolInputs[toolId] {
                    continuation.yield(StreamDelta(text: nil, toolCallId: toolId, toolCallName: tool.name, toolCallArguments: tool.argChunks, finishReason: "tool_calls"))
                    pendingToolInputs.removeValue(forKey: toolId)
                }
            }

        case "3":
            if let data = content.data(using: .utf8),
               let errorText = try? JSONSerialization.jsonObject(with: data) as? String {
                continuation.yield(StreamDelta(text: "Error: \(errorText)", toolCallId: nil, toolCallName: nil, toolCallArguments: nil, finishReason: "error"))
            }

        default:
            break
        }
    }

    func searchListings(filters: SearchFilters) -> [Listing] {
        var results = MockData.listings

        if let minBeds = filters.minBeds {
            results = results.filter { $0.beds >= minBeds }
        }
        if let maxBeds = filters.maxBeds {
            results = results.filter { $0.beds <= maxBeds }
        }
        if let minBaths = filters.minBaths {
            results = results.filter { $0.baths >= minBaths }
        }
        if let maxBaths = filters.maxBaths {
            results = results.filter { $0.baths <= maxBaths }
        }
        if let minPrice = filters.minPrice {
            results = results.filter { $0.price >= minPrice }
        }
        if let maxPrice = filters.maxPrice {
            results = results.filter { $0.price <= maxPrice }
        }
        if let minSqft = filters.minSqft {
            results = results.filter { $0.sqft >= minSqft }
        }
        if let maxSqft = filters.maxSqft {
            results = results.filter { $0.sqft <= maxSqft }
        }
        if let propertyType = filters.propertyType {
            results = results.filter { $0.propertyType.lowercased() == propertyType.lowercased() }
        }
        if let isHotHome = filters.isHotHome, isHotHome {
            results = results.filter { $0.isHotHome }
        }
        if let neighborhoods = filters.neighborhoods, !neighborhoods.isEmpty {
            let lowerNeighborhoods = neighborhoods.map { $0.lowercased() }
            results = results.filter { listing in
                lowerNeighborhoods.contains(where: { listing.city.lowercased().contains($0) })
            }
        }

        return results
    }
}

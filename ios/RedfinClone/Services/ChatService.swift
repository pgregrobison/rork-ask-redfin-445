import Foundation

nonisolated struct StreamEvent: Sendable {
    enum Kind: Sendable {
        case textDelta(String)
        case toolCallStart(toolCallId: String, toolName: String)
        case toolCallDelta(toolCallId: String, argsDelta: String)
        case toolCallReady(toolCallId: String, toolName: String, input: String)
        case done
        case error(String)
    }
    let kind: Kind
}

@MainActor
class ChatService {
    private var toolkitURL: String { Self.env("EXPO_PUBLIC_TOOLKIT_URL") }
    private var projectId: String { Self.env("EXPO_PUBLIC_PROJECT_ID") }
    private var teamId: String { Self.env("EXPO_PUBLIC_TEAM_ID") }
    private var appKey: String { Self.env("EXPO_PUBLIC_RORK_APP_KEY") }

    private nonisolated static func env(_ key: String) -> String {
        if let v = Bundle.main.infoDictionary?[key] as? String,
           !v.isEmpty, !v.hasPrefix("$(") { return v }
        if let v = ProcessInfo.processInfo.environment[key], !v.isEmpty { return v }
        return ""
    }

    private let systemPrompt = """
    You are Ask Redfin, an AI-powered real estate assistant. You help users find homes in the NYC metro area (Manhattan, Brooklyn, Queens, Long Island City, Astoria).

    When users ask to find homes, apartments, condos, or properties, call the searchListings tool with appropriate filters.

    If a user asks about properties outside NYC, let them know your listings currently cover the NYC metro area.

    Keep responses brief and direct. When you call searchListings, don't describe individual results — listing cards appear automatically. Just acknowledge the search briefly.
    """

    func sendMessage(messages: [ChatMessage]) -> AsyncStream<StreamEvent> {
        let url = toolkitURL
        let proj = projectId
        let team = teamId
        let app = appKey
        let sysPrompt = systemPrompt

        let apiMessages = Self.buildAPIMessages(from: messages)
        let tools = Self.buildTools()

        return AsyncStream { continuation in
            Task.detached {
                await Self.performStream(
                    baseURL: url,
                    projectId: proj,
                    teamId: team,
                    appKey: app,
                    systemPrompt: sysPrompt,
                    messages: apiMessages,
                    tools: tools,
                    continuation: continuation
                )
            }
        }
    }

    private nonisolated static func buildAPIMessages(from messages: [ChatMessage]) -> [[String: Any]] {
        var result: [[String: Any]] = []

        for msg in messages {
            switch msg.role {
            case .user:
                result.append([
                    "role": "user",
                    "content": msg.content
                ])

            case .assistant:
                if let toolCalls = msg.toolCalls, !toolCalls.isEmpty {
                    var parts: [[String: Any]] = []

                    if !msg.content.isEmpty {
                        parts.append(["type": "text", "text": msg.content])
                    }

                    for tc in toolCalls {
                        var inputObj: Any = [String: Any]()
                        if let argsData = tc.arguments.data(using: .utf8),
                           let parsed = try? JSONSerialization.jsonObject(with: argsData) {
                            inputObj = parsed
                        }

                        parts.append([
                            "type": "tool-call",
                            "toolCallId": tc.id,
                            "toolName": tc.name,
                            "args": inputObj
                        ])
                    }

                    result.append(["role": "assistant", "content": parts])

                    for tc in toolCalls {
                        result.append([
                            "role": "tool",
                            "content": [
                                [
                                    "type": "tool-result",
                                    "toolCallId": tc.id,
                                    "toolName": tc.name,
                                    "result": tc.result ?? ""
                                ] as [String: Any]
                            ]
                        ])
                    }
                } else if !msg.content.isEmpty {
                    result.append([
                        "role": "assistant",
                        "content": msg.content
                    ])
                }

            case .system, .tool:
                break
            }
        }

        return result
    }

    private nonisolated static func buildTools() -> [String: Any] {
        return [
            "searchListings": [
                "description": "Search for home listings in NYC. Use when the user asks to find homes, apartments, condos, or properties.",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "minBeds": ["type": "integer", "description": "Minimum bedrooms"],
                        "maxBeds": ["type": "integer", "description": "Maximum bedrooms"],
                        "minPrice": ["type": "integer", "description": "Minimum price in dollars"],
                        "maxPrice": ["type": "integer", "description": "Maximum price in dollars"],
                        "propertyType": ["type": "string", "description": "Property type", "enum": ["Condo", "Townhouse", "Co-op"]],
                        "isHotHome": ["type": "boolean", "description": "Only hot homes"],
                        "neighborhoods": ["type": "array", "description": "Neighborhoods", "items": ["type": "string"]]
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any]
        ]
    }

    private nonisolated static func performStream(
        baseURL: String,
        projectId: String,
        teamId: String,
        appKey: String,
        systemPrompt: String,
        messages: [[String: Any]],
        tools: [String: Any],
        continuation: AsyncStream<StreamEvent>.Continuation
    ) async {
        guard !baseURL.isEmpty else {
            continuation.yield(StreamEvent(kind: .error("Toolkit URL not configured.")))
            continuation.finish()
            return
        }

        guard let endpoint = URL(string: "\(baseURL)/agent/chat") else {
            continuation.yield(StreamEvent(kind: .error("Invalid toolkit URL.")))
            continuation.finish()
            return
        }

        let body: [String: Any] = [
            "messages": messages,
            "tools": tools,
            "system": systemPrompt
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            continuation.yield(StreamEvent(kind: .error("Failed to build request.")))
            continuation.finish()
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !projectId.isEmpty { request.setValue(projectId, forHTTPHeaderField: "x-project-id") }
        if !teamId.isEmpty { request.setValue(teamId, forHTTPHeaderField: "x-team-id") }
        if !appKey.isEmpty { request.setValue(appKey, forHTTPHeaderField: "x-app-key") }
        request.httpBody = bodyData
        request.timeoutInterval = 60

        do {
            let (bytes, response) = try await URLSession.shared.bytes(for: request)

            guard let http = response as? HTTPURLResponse else {
                continuation.yield(StreamEvent(kind: .error("Invalid server response.")))
                continuation.finish()
                return
            }

            guard (200...299).contains(http.statusCode) else {
                var errorBody = ""
                do {
                    var data = Data()
                    for try await byte in bytes {
                        data.append(byte)
                        if data.count > 4096 { break }
                    }
                    errorBody = String(data: data, encoding: .utf8) ?? ""
                } catch {}
                continuation.yield(StreamEvent(kind: .error("Error \(http.statusCode): \(errorBody.prefix(300))")))
                continuation.finish()
                return
            }

            var pendingTools: [String: (name: String, argsBuffer: String)] = [:]

            for try await line in bytes.lines {
                guard line.hasPrefix("data: ") else { continue }
                let payload = String(line.dropFirst(6))

                if payload == "[DONE]" {
                    for (toolId, tool) in pendingTools {
                        continuation.yield(StreamEvent(kind: .toolCallReady(toolCallId: toolId, toolName: tool.name, input: tool.argsBuffer)))
                    }
                    pendingTools.removeAll()
                    continuation.yield(StreamEvent(kind: .done))
                    break
                }

                guard let data = payload.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let type = json["type"] as? String else { continue }

                switch type {
                case "text-delta":
                    if let delta = json["textDelta"] as? String {
                        continuation.yield(StreamEvent(kind: .textDelta(delta)))
                    } else if let delta = json["delta"] as? String {
                        continuation.yield(StreamEvent(kind: .textDelta(delta)))
                    }

                case "tool-call":
                    let toolId = json["toolCallId"] as? String ?? UUID().uuidString
                    let toolName = json["toolName"] as? String ?? ""
                    let args: String
                    if let argsObj = json["args"] {
                        if let d = try? JSONSerialization.data(withJSONObject: argsObj) {
                            args = String(data: d, encoding: .utf8) ?? "{}"
                        } else { args = "{}" }
                    } else {
                        args = pendingTools[toolId]?.argsBuffer ?? "{}"
                    }
                    pendingTools.removeValue(forKey: toolId)
                    continuation.yield(StreamEvent(kind: .toolCallReady(toolCallId: toolId, toolName: toolName, input: args)))

                case "tool-call-streaming-start", "tool-input-start":
                    if let toolId = json["toolCallId"] as? String,
                       let toolName = json["toolName"] as? String {
                        pendingTools[toolId] = (name: toolName, argsBuffer: "")
                        continuation.yield(StreamEvent(kind: .toolCallStart(toolCallId: toolId, toolName: toolName)))
                    }

                case "tool-call-delta":
                    if let toolId = json["toolCallId"] as? String,
                       let delta = json["argsTextDelta"] as? String {
                        pendingTools[toolId]?.argsBuffer += delta
                        continuation.yield(StreamEvent(kind: .toolCallDelta(toolCallId: toolId, argsDelta: delta)))
                    }

                case "tool-input-delta":
                    if let toolId = json["toolCallId"] as? String,
                       let delta = json["inputTextDelta"] as? String {
                        pendingTools[toolId]?.argsBuffer += delta
                        continuation.yield(StreamEvent(kind: .toolCallDelta(toolCallId: toolId, argsDelta: delta)))
                    }

                case "tool-input-available":
                    if let toolId = json["toolCallId"] as? String,
                       let toolName = json["toolName"] as? String {
                        let args: String
                        if let input = json["input"] {
                            if let d = try? JSONSerialization.data(withJSONObject: input) {
                                args = String(data: d, encoding: .utf8) ?? "{}"
                            } else { args = "{}" }
                        } else {
                            args = pendingTools[toolId]?.argsBuffer ?? "{}"
                        }
                        pendingTools.removeValue(forKey: toolId)
                        continuation.yield(StreamEvent(kind: .toolCallReady(toolCallId: toolId, toolName: toolName, input: args)))
                    }

                case "start", "text-start", "text-end", "message-start", "message-finish",
                     "step-start", "step-finish", "tool-output-available", "finish", "abort",
                     "ping", "source":
                    break

                default:
                    break
                }
            }

            continuation.finish()
        } catch {
            continuation.yield(StreamEvent(kind: .error("Connection failed: \(error.localizedDescription)")))
            continuation.finish()
        }
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
}

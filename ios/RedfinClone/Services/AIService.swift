import Foundation

nonisolated enum AIError: Error, Sendable {
    case missingConfig
    case unauthorized
    case insufficientBalance
    case rateLimited
    case server(Int)
    case transport(String)

    var userFacing: String {
        switch self {
        case .missingConfig: return "AI is not configured."
        case .unauthorized: return "AI authentication failed."
        case .insufficientBalance: return "AI credits exhausted."
        case .rateLimited: return "Too many requests, please try again."
        case .server(let code): return "AI server error (\(code))."
        case .transport(let msg): return "Connection problem: \(msg)"
        }
    }
}

nonisolated enum AIEvent: Sendable {
    case textDelta(String)
    case toolCallStart(index: Int, id: String, name: String)
    case toolCallArgsDelta(index: Int, json: String)
    case finish(reason: String?)
}

nonisolated struct AIMessage: Sendable {
    let role: String
    let content: String?
    let toolCalls: [PendingToolCall]?
    let toolCallId: String?

    init(role: String, content: String?, toolCalls: [PendingToolCall]? = nil, toolCallId: String? = nil) {
        self.role = role
        self.content = content
        self.toolCalls = toolCalls
        self.toolCallId = toolCallId
    }
}

nonisolated struct PendingToolCall: Sendable, Hashable {
    let id: String
    let name: String
    let arguments: String
}

nonisolated struct AIToolSchema: @unchecked Sendable {
    let name: String
    let description: String
    let parameters: [String: Any]

    func asDictionary() -> [String: Any] {
        [
            "type": "function",
            "function": [
                "name": name,
                "description": description,
                "parameters": parameters
            ]
        ]
    }
}

nonisolated final class AIService: Sendable {
    private let model = "anthropic/claude-sonnet-4.6"

    private var baseURL: String {
        (Bundle.main.object(forInfoDictionaryKey: "EXPO_PUBLIC_TOOLKIT_URL") as? String) ?? ""
    }

    private var apiKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY") as? String) ?? ""
    }

    func stream(messages: [AIMessage], tools: [AIToolSchema]) -> AsyncThrowingStream<AIEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await runStream(messages: messages, tools: tools, continuation: continuation)
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private func runStream(
        messages: [AIMessage],
        tools: [AIToolSchema],
        continuation: AsyncThrowingStream<AIEvent, Error>.Continuation
    ) async throws {
        let base = baseURL.trimmingCharacters(in: .whitespaces)
        guard !base.isEmpty, !apiKey.isEmpty,
              let url = URL(string: "\(base)/v2/vercel/v1/chat/completions") else {
            throw AIError.missingConfig
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 90

        let body: [String: Any] = [
            "model": model,
            "messages": messages.map { encodeMessage($0) },
            "stream": true,
            "tools": tools.map { $0.asDictionary() },
            "tool_choice": "auto",
            "temperature": 0.5,
            "max_tokens": 1024
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (bytes, response) = try await URLSession.shared.bytes(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AIError.transport("Invalid response")
        }
        if http.statusCode >= 400 {
            switch http.statusCode {
            case 401: throw AIError.unauthorized
            case 402: throw AIError.insufficientBalance
            case 429: throw AIError.rateLimited
            default: throw AIError.server(http.statusCode)
            }
        }

        for try await line in bytes.lines {
            if Task.isCancelled { return }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("data: ") else { continue }
            let payload = String(trimmed.dropFirst(6))
            if payload.isEmpty || payload == "[DONE]" { continue }
            guard let data = payload.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = obj["choices"] as? [[String: Any]],
                  let choice = choices.first else { continue }

            if let delta = choice["delta"] as? [String: Any] {
                if let content = delta["content"] as? String, !content.isEmpty {
                    continuation.yield(.textDelta(content))
                }
                if let toolCalls = delta["tool_calls"] as? [[String: Any]] {
                    for tc in toolCalls {
                        let index = (tc["index"] as? Int) ?? 0
                        let function = tc["function"] as? [String: Any]
                        if let id = tc["id"] as? String, let name = function?["name"] as? String {
                            continuation.yield(.toolCallStart(index: index, id: id, name: name))
                        }
                        if let args = function?["arguments"] as? String, !args.isEmpty {
                            continuation.yield(.toolCallArgsDelta(index: index, json: args))
                        }
                    }
                }
            }

            if let reason = choice["finish_reason"] as? String {
                continuation.yield(.finish(reason: reason))
            }
        }
    }

    private func encodeMessage(_ m: AIMessage) -> [String: Any] {
        var dict: [String: Any] = ["role": m.role]
        dict["content"] = m.content ?? ""
        if let calls = m.toolCalls, !calls.isEmpty {
            dict["tool_calls"] = calls.map { call in
                [
                    "id": call.id,
                    "type": "function",
                    "function": [
                        "name": call.name,
                        "arguments": call.arguments
                    ]
                ] as [String: Any]
            }
        }
        if let toolCallId = m.toolCallId {
            dict["tool_call_id"] = toolCallId
        }
        return dict
    }
}

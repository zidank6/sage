import Foundation

/// Service for interacting with xAI Chat Completions API
actor xAIService {
    private let baseURL = "https://api.x.ai/v1/chat/completions"
    private let config = ConfigService.shared
    
    /// System prompt - strict limit for Free users
    private let systemPromptFree = """
    You are Sage, a witty AI assistant for iMessage.
    Tone: Casual, punchy, like a smart friend.
    Length: STRICTLY under 150 characters.
    Info: You have real-time access to X. Use it for current events.
    Structure: Direct answer first. Then 1 context detail.
    Rules:
    1. NO branding.
    2. Be accurate but fun.
    3. If asked for unsafe stuff, piviot to science/history.
    4. Emoji encouraged.
    """
    
    /// System prompt - relaxed for Premium users
    private let systemPromptPremium = """
    Role: Sage, the smartest, most convenient iMessage friend.
    Info: You have real-time access to X. Use it for current events.
    Structure: Max 300 chars. NO prefixes.
    Style: Direct, witty, detailed.
    Rules:
    1. KEY ANSWER FIRST.
    2. Provide context from real-time info if relevant.
    3. No filler. No apologies.
    4. Use emoji naturally.
    """
    
    // MARK: - Legacy Methods Removed
    // sendMessage, buildRequest, and validateResponse were removed as we now use streamMessage directly
    
    // MARK: - Streaming Request
    
    func streamMessage(_ content: String, context: String?, history: [ChatMessage], isPremium: Bool = false) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard config.isConfigured else {
                        throw xAIError.notConfigured
                    }
                    
                    // Build messages array
                    var messages: [APIMessage] = []
                    
                    // 1. System Prompt (Dynamic based on premium)
                    let prompt = isPremium ? systemPromptPremium : systemPromptFree
                    messages.append(APIMessage(role: "system", content: prompt))
                    
                    // 2. Context (if any)
                    if let context = context, !context.isEmpty {
                        messages.append(APIMessage(role: "user", content: "Context: \(context)"))
                    }
                    
                    // 3. User Message
                    messages.append(APIMessage(role: "user", content: content))
                    
                    // Configuration
                    let maxTokens = isPremium ? 1024 : (config.maxTokens ?? 300)
                    let model = isPremium ? "grok-3" : "grok-3-mini"
                    
                    let requestBody = ChatCompletionRequest(
                        model: model,
                        messages: messages,
                        temperature: config.temperature ?? 0.7,
                        maxTokens: maxTokens,
                        stream: true,
                        searchParameters: SearchParameters(mode: "on")
                    )
                    
                    // Create URL Request for Streaming
                    guard let url = URL(string: baseURL) else {
                        throw xAIError.invalidURL
                    }
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.addValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpBody = try JSONEncoder().encode(requestBody)
                    
                    let (stream, response) = try await URLSession.shared.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw xAIError.invalidResponse
                    }
                    
                    guard httpResponse.statusCode == 200 else {
                        // Attempt to read error details
                        var errorText = ""
                        for try await byte in stream {
                            if let char = String(bytes: [byte], encoding: .utf8) {
                                errorText += char
                            }
                        }
                        throw xAIError.httpError(statusCode: httpResponse.statusCode, message: errorText)
                    }
                    
                    // Parse SSE Stream
                    for try await line in stream.lines {
                        if line.hasPrefix("data: "), line != "data: [DONE]" {
                            let json = line.dropFirst(6)
                            if let data = json.data(using: .utf8),
                               let chunk = try? JSONDecoder().decode(ChatCompletionChunk.self, from: data),
                               let content = chunk.choices.first?.delta.content {
                                continuation.yield(content)
                            }
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Legacy Methods Removed
    // buildRequest and validateResponse were removed as we now use streamMessage directly
}

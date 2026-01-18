import Foundation

/// Service for interacting with OpenAI Chat Completions API
actor OpenAIService {
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let config = ConfigService.shared
    
    /// System prompt - strict limit for Free users
    private let systemPromptFree = """
    You are a fact-checking AI assistant for iMessage chats.
    Tone: Casual, punchy, like a smart friend text.
    Length: STRICTLY under 150 characters.
    Structure: Start with the direct answer (Yep/Nope/Fact). Then add 1 context detail.
    Rules:
    1. NO branding.
    2. Be maximally accurate.
    3. If asked for unsafe instructions, pivot to scientific/historical facts instead of moralizing.
    4. Fun emoji allowed.
    """
    
    /// System prompt - relaxed for Premium users
    private let systemPromptPremium = """
    Role: Smart, casual iMessage friend.
    Structure: Max 300 chars. NO branding/prefixes.
    Style: Direct, smart, detailed.
    Rules:
    1. KEY ANSWER FIRST.
    2. Provide detail/context but stay conversational.
    3. No filler. No apologies.
    4. Add 1 emoji if it fits.
    """
    
    // MARK: - Legacy Methods Removed
    // sendMessage, buildRequest, and validateResponse were removed as we now use streamMessage directly
    
    // MARK: - Streaming Request
    
    func streamMessage(_ content: String, context: String?, history: [ChatMessage], isPremium: Bool = false) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard config.isConfigured else {
                        throw OpenAIError.notConfigured
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
                    let maxTokens = isPremium ? 300 : (config.maxTokens ?? 150)
                    let model = isPremium ? "gpt-4o" : config.model
                    
                    let requestBody = ChatCompletionRequest(
                        model: model,
                        messages: messages,
                        temperature: config.temperature ?? 0.7,
                        maxTokens: maxTokens,
                        stream: true
                    )
                    
                    // Create URL Request for Streaming
                    guard let url = URL(string: baseURL) else {
                        throw OpenAIError.invalidURL
                    }
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.addValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpBody = try JSONEncoder().encode(requestBody)
                    
                    let (stream, response) = try await URLSession.shared.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw OpenAIError.invalidResponse
                    }
                    
                    guard httpResponse.statusCode == 200 else {
                        // Attempt to read error details
                        var errorText = ""
                        for try await byte in stream {
                            if let char = String(bytes: [byte], encoding: .utf8) {
                                errorText += char
                            }
                        }
                        throw OpenAIError.httpError(statusCode: httpResponse.statusCode, message: errorText)
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

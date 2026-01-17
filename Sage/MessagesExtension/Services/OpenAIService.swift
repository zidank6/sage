import Foundation

/// Service for interacting with OpenAI Chat Completions API
actor OpenAIService {
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let config = ConfigService.shared
    
    /// System prompt for Sage assistant
    private let systemPrompt = """
    You are Sage, a helpful, concise assistant in iMessage chats. \
    Answer accurately, cite sources if factual, keep replies under 300 words.
    """
    
    // MARK: - Non-Streaming Request
    
    /// Send a chat completion request (non-streaming)
    func sendMessage(_ text: String, context: String? = nil, history: [ChatMessage] = []) async throws -> String {
        guard config.isConfigured else {
            throw OpenAIError.notConfigured
        }
        
        let request = try buildRequest(text: text, context: context, history: history, stream: false)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try validateResponse(response, data: data)
        
        let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        
        guard let content = chatResponse.choices.first?.message.content else {
            throw OpenAIError.invalidResponse
        }
        
        return content
    }
    
    // MARK: - Streaming Request
    
    /// Send a streaming chat completion request
    func streamMessage(_ text: String, context: String? = nil, history: [ChatMessage] = []) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard config.isConfigured else {
                        throw OpenAIError.notConfigured
                    }
                    
                    let request = try buildRequest(text: text, context: context, history: history, stream: true)
                    
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw OpenAIError.invalidResponse
                    }
                    
                    if httpResponse.statusCode != 200 {
                        // Collect error response
                        var errorData = Data()
                        for try await byte in bytes {
                            errorData.append(byte)
                        }
                        try validateResponse(response, data: errorData)
                    }
                    
                    // Parse SSE stream
                    for try await line in bytes.lines {
                        // SSE format: each line starts with "data: "
                        guard line.hasPrefix("data: ") else { continue }
                        
                        let jsonString = String(line.dropFirst(6))
                        
                        // Check for [DONE] marker
                        if jsonString == "[DONE]" {
                            break
                        }
                        
                        // Parse JSON chunk
                        guard let jsonData = jsonString.data(using: .utf8) else { continue }
                        
                        do {
                            let chunk = try JSONDecoder().decode(ChatCompletionChunk.self, from: jsonData)
                            
                            if let content = chunk.choices.first?.delta.content {
                                continuation.yield(content)
                            }
                            
                            // Check for finish_reason
                            if chunk.choices.first?.finishReason != nil {
                                break
                            }
                        } catch {
                            // Skip malformed chunks but log
                            print("⚠️ Failed to parse chunk: \(jsonString)")
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func buildRequest(text: String, context: String?, history: [ChatMessage], stream: Bool) throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        
        // Build messages array
        var messages: [APIMessage] = [
            APIMessage(role: "system", content: systemPrompt)
        ]
        
        // Add conversation history
        for msg in history {
            messages.append(APIMessage(role: msg.role.rawValue, content: msg.content))
        }
        
        // Build user message with optional context
        var userContent = text
        if let context = context, !context.isEmpty {
            userContent = "Context from conversation: \"\(context)\"\n\nQuestion: \(text)"
        }
        messages.append(APIMessage(role: "user", content: userContent))
        
        let body = ChatCompletionRequest(
            model: config.model,
            messages: messages,
            temperature: config.temperature,
            maxTokens: config.maxTokens,
            stream: stream
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        return request
    }
    
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            // Try to parse error response
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw OpenAIError.httpError(
                    statusCode: httpResponse.statusCode,
                    message: apiError.error.message
                )
            }
            throw OpenAIError.httpError(
                statusCode: httpResponse.statusCode,
                message: "Unknown error"
            )
        }
    }
}

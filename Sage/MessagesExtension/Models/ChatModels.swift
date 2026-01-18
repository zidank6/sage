import Foundation

// MARK: - Request Models

/// xAI Chat Completions API request
struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [APIMessage]
    let temperature: Double
    let maxTokens: Int
    let stream: Bool
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature, stream
        case maxTokens = "max_tokens"
    }
}

/// Message format for xAI API
struct APIMessage: Codable {
    let role: String
    let content: String
}

// MARK: - Response Models (Non-Streaming)

/// xAI Chat Completions API response
struct ChatCompletionResponse: Decodable {
    let id: String
    let choices: [Choice]
    let usage: Usage?
    
    struct Choice: Decodable {
        let index: Int
        let message: APIMessage
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index, message
            case finishReason = "finish_reason"
        }
    }
    
    struct Usage: Decodable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

// MARK: - Streaming Response Models

/// Streaming chunk from xAI API (SSE format)
struct ChatCompletionChunk: Decodable {
    let id: String
    let choices: [StreamChoice]
    
    struct StreamChoice: Decodable {
        let index: Int
        let delta: Delta
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index, delta
            case finishReason = "finish_reason"
        }
    }
    
    struct Delta: Decodable {
        let role: String?
        let content: String?
    }
}

// MARK: - Error Models

/// xAI API error response
struct APIError: Decodable, Error {
    let error: ErrorDetail
    
    struct ErrorDetail: Decodable {
        let message: String
        let type: String
        let code: String?
    }
    
    var localizedDescription: String {
        error.message
    }
}

/// Custom errors for xAI service
enum xAIError: LocalizedError {
    case notConfigured
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case streamingError(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "API key not configured. Check Config.plist."
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let code, let message):
            return "API error (\(code)): \(message)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .streamingError(let message):
            return "Streaming error: \(message)"
        }
    }
}

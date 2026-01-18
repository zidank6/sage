import Foundation

/// Represents a single chat message
struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: Role
    var content: String
    let timestamp: Date
    
    enum Role: String, Codable {
        case user
        case assistant
        case system
    }
    
    init(id: UUID = UUID(), role: Role, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

/// Observable state for the chat interface
@Observable
class ChatState {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedContext: String?
    var lastSentMessage: String?
    
    /// Current model for API calls
    var model: String = "grok-3"
    
    /// System prompt for the assistant
    let systemPrompt = """
    You are Sage, a helpful, concise assistant in iMessage chats. \
    Answer accurately, cite sources if factual, keep replies under 300 words.
    """
}

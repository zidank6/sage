import SwiftUI

/// Individual chat bubble view for messages
struct ChatBubbleView: View {
    let message: ChatMessage
    var onSendToChat: ((String) -> Void)?
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                // Role label
                HStack(spacing: 4) {
                    if message.role == .assistant {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                    }
                    Text(message.role == .user ? "You" : "Sage")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Message content
                Text(message.content)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding(12)
                    .background(bubbleBackground)
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Send to chat button (for assistant messages with content)
                if message.role == .assistant && !message.content.isEmpty {
                    Button {
                        onSendToChat?(formatForChat(message.content))
                    } label: {
                        Label("Send to Chat", systemImage: "arrow.turn.down.right")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
    }
    
    private var bubbleBackground: Color {
        message.role == .user ? .blue : Color(.secondarySystemBackground)
    }
    
    /// Format the response for insertion into chat
    private func formatForChat(_ content: String) -> String {
        "Sage: \(content)"
    }
}

#Preview {
    VStack(spacing: 20) {
        ChatBubbleView(message: ChatMessage(role: .user, content: "Hello, what's the weather like?"))
        ChatBubbleView(
            message: ChatMessage(role: .assistant, content: "I don't have access to real-time weather data, but I can help you find weather information for your location!"),
            onSendToChat: { text in print(text) }
        )
    }
    .padding()
}

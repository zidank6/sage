import SwiftUI

/// Compact mode view: Full interaction in the bottom drawer
/// Shows input, response, and send-to-chat all in compact space
struct CompactView: View {
    @Bindable var chatState: ChatState
    let onSendToChat: (String) -> Void
    
    private let openAI = OpenAIService()
    
    var body: some View {
        VStack(spacing: 8) {
            // Response area (only shows when there's a response or loading)
            if chatState.isLoading || !currentResponse.isEmpty {
                responseArea
            }
            
            // Input bar - always visible
            inputBar
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Subviews
    
    private var responseArea: some View {
        HStack(alignment: .top, spacing: 10) {
            // Sage icon
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(.blue)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                // Response text or loading
                if chatState.isLoading && currentResponse.isEmpty {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Thinking...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(currentResponse)
                        .font(.subheadline)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Send to chat button
                if !currentResponse.isEmpty && !chatState.isLoading {
                    Button {
                        onSendToChat("Sage: \(currentResponse)")
                        clearResponse()
                    } label: {
                        Label("Send", systemImage: "arrow.up.circle.fill")
                            .font(.caption.bold())
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            
            Spacer()
            
            // Dismiss response button
            if !currentResponse.isEmpty && !chatState.isLoading {
                Button {
                    clearResponse()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var inputBar: some View {
        HStack(spacing: 10) {
            // Sage icon
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(.blue)
            
            // Input field
            TextField("Ask Sage...", text: $chatState.inputText)
                .textFieldStyle(.plain)
                .font(.body)
                .onSubmit {
                    sendMessage()
                }
            
            // Send button
            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canSend ? .blue : .gray)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
    
    // MARK: - Helpers
    
    private var currentResponse: String {
        chatState.messages.last(where: { $0.role == .assistant })?.content ?? ""
    }
    
    private var canSend: Bool {
        !chatState.inputText.trimmingCharacters(in: .whitespaces).isEmpty && !chatState.isLoading
    }
    
    private func clearResponse() {
        chatState.messages.removeAll()
    }
    
    private func sendMessage() {
        let text = chatState.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !chatState.isLoading else { return }
        
        // Clear previous response
        chatState.messages.removeAll()
        
        // Add user message
        let userMessage = ChatMessage(role: .user, content: text)
        chatState.messages.append(userMessage)
        chatState.inputText = ""
        chatState.isLoading = true
        chatState.errorMessage = nil
        
        Task {
            do {
                // Create placeholder for streaming response
                let responseMessage = ChatMessage(role: .assistant, content: "")
                await MainActor.run {
                    chatState.messages.append(responseMessage)
                }
                let responseIndex = await MainActor.run { chatState.messages.count - 1 }
                
                // Stream response from OpenAI
                let stream = await openAI.streamMessage(text, context: nil, history: [])
                for try await chunk in stream {
                    await MainActor.run {
                        chatState.messages[responseIndex].content += chunk
                    }
                }
                
                await MainActor.run {
                    chatState.isLoading = false
                }
            } catch {
                await MainActor.run {
                    chatState.isLoading = false
                    chatState.errorMessage = error.localizedDescription
                    
                    // Show error inline
                    if chatState.messages.count > 1 {
                        chatState.messages[chatState.messages.count - 1].content = "Error: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        CompactView(
            chatState: ChatState(),
            onSendToChat: { _ in }
        )
    }
}

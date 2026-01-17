import SwiftUI

/// Compact mode view: Minimal input at top of drawer
struct CompactView: View {
    @Bindable var chatState: ChatState
    let onSendToChat: (String) -> Void
    
    private let openAI = OpenAIService()
    
    var body: some View {
        VStack(spacing: 8) {
            // Input bar - at top
            inputBar
            
            // Response area (only when there's content)
            if chatState.isLoading || !currentResponse.isEmpty {
                responseArea
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Subviews
    
    private var responseArea: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
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
                }
                
                // Action buttons
                if !currentResponse.isEmpty && !chatState.isLoading {
                    HStack(spacing: 8) {
                        Button {
                            onSendToChat(currentResponse)
                            clearResponse()
                        } label: {
                            Text("Send")
                                .font(.caption.bold())
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        
                        Button { clearResponse() } label: {
                            Image(systemName: "xmark")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Ask anything...", text: $chatState.inputText)
                .textFieldStyle(.plain)
                .font(.body)
                .onSubmit { sendMessage() }
            
            Button { sendMessage() } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canSend ? .blue : .gray.opacity(0.5))
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.tertiarySystemBackground))
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
        
        chatState.messages.removeAll()
        chatState.messages.append(ChatMessage(role: .user, content: text))
        chatState.inputText = ""
        chatState.isLoading = true
        
        Task {
            do {
                let responseMessage = ChatMessage(role: .assistant, content: "")
                await MainActor.run { chatState.messages.append(responseMessage) }
                let responseIndex = await MainActor.run { chatState.messages.count - 1 }
                
                let stream = await openAI.streamMessage(text, context: nil, history: [])
                for try await chunk in stream {
                    await MainActor.run { chatState.messages[responseIndex].content += chunk }
                }
                
                await MainActor.run { chatState.isLoading = false }
            } catch {
                await MainActor.run {
                    chatState.isLoading = false
                    if chatState.messages.count > 1 {
                        chatState.messages[chatState.messages.count - 1].content = "Error: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

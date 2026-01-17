import SwiftUI

/// Expanded mode view: full chat history with input
struct ExpandedView: View {
    @Bindable var chatState: ChatState
    let onSendToChat: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Chat history
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Context banner if available
                        if let context = chatState.selectedContext {
                            contextBanner(context)
                        }
                        
                        // Messages
                        ForEach(chatState.messages) { message in
                            ChatBubbleView(message: message, onSendToChat: onSendToChat)
                                .id(message.id)
                        }
                        
                        // Loading indicator
                        if chatState.isLoading {
                            loadingIndicator
                        }
                    }
                    .padding()
                }
                .onChange(of: chatState.messages.count) { _, _ in
                    if let lastMessage = chatState.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Error message
            if let error = chatState.errorMessage {
                errorBanner(error)
            }
            
            Divider()
            
            // Input bar
            inputBar
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Image(systemName: "message.badge.waveform.fill")
                .foregroundStyle(.blue)
            Text("Sage")
                .font(.headline)
            Spacer()
            
            // Privacy indicator
            Image(systemName: "icloud")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func contextBanner(_ context: String) -> some View {
        HStack {
            Image(systemName: "quote.opening")
                .foregroundStyle(.secondary)
            Text(context)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer()
            Button {
                chatState.selectedContext = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var loadingIndicator: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Sage is thinking...")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private func errorBanner(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(error)
                .font(.caption)
            Spacer()
            Button("Retry") {
                chatState.errorMessage = nil
                // Retry logic will be added in Phase 4
            }
            .font(.caption.bold())
        }
        .padding(10)
        .background(Color.orange.opacity(0.1))
    }
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask a question...", text: $chatState.inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundStyle(chatState.inputText.isEmpty || chatState.isLoading ? .gray : .blue)
            }
            .disabled(chatState.inputText.isEmpty || chatState.isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Actions
    
    private let openAI = OpenAIService()
    
    private func sendMessage() {
        let text = chatState.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(role: .user, content: text)
        chatState.messages.append(userMessage)
        chatState.inputText = ""
        chatState.isLoading = true
        chatState.errorMessage = nil
        
        // Build history for context (exclude current message)
        let history = Array(chatState.messages.dropLast())
        let context = chatState.selectedContext
        
        Task {
            do {
                // Create placeholder for streaming response
                let responseMessage = ChatMessage(role: .assistant, content: "")
                await MainActor.run {
                    chatState.messages.append(responseMessage)
                }
                let responseIndex = await MainActor.run { chatState.messages.count - 1 }
                
                // Stream response from OpenAI
                let stream = await openAI.streamMessage(text, context: context, history: history)
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
                    
                    // Remove empty assistant message on error
                    if let last = chatState.messages.last, last.role == .assistant && last.content.isEmpty {
                        chatState.messages.removeLast()
                    }
                }
            }
        }
    }
}

#Preview {
    ExpandedView(
        chatState: {
            let state = ChatState()
            state.messages = [
                ChatMessage(role: .user, content: "What's the capital of France?"),
                ChatMessage(role: .assistant, content: "The capital of France is Paris.")
            ]
            return state
        }(),
        onSendToChat: { _ in }
    )
}

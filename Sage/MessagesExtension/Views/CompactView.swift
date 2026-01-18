import SwiftUI

/// Compact mode view: Premium, glassmorphic design
struct CompactView: View {
    @Bindable var chatState: ChatState
    let onSendToChat: (String) -> Void
    
    private let openAI = OpenAIService()
    @State private var usageService = UsageService.shared
    @State private var subService = SubscriptionService.shared
    @State private var showUpgrade = false
    
    // Animation states
    @State private var isInputFocused = false
    @State private var isBreathing = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main Content
            VStack(spacing: 12) {
                // Input Layout
                inputSection
                
                // Response Preview (only when needed)
                if shouldShowResponse {
                    responseSection
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Limit Overlay
            if showLimitOverlay {
                limitReachedOverlay
                    .transition(.opacity.animation(.easeInOut))
                    .zIndex(100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                Color(.systemGray5)
                    .ignoresSafeArea()
                    .opacity(isBreathing ? 0.2 : 0.0)
                    .animation(
                        .easeInOut(duration: 5.0)
                        .repeatForever(autoreverses: true),
                        value: isBreathing
                    )
            }
        }
        .onAppear {
            isBreathing = true
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: shouldShowResponse)
        .animation(.easeInOut, value: showLimitOverlay)
    }
    
    // MARK: - Components
    
    private var inputSection: some View {
        HStack(spacing: 12) {
            // Decoration
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isPremium ? AnyShapeStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.secondary))
            
            // Text Input
            TextField("What's up? ✨", text: $chatState.inputText)
                .textFieldStyle(.plain)
                .font(.system(.body, design: .default))
                .onSubmit { sendMessage() }
                .disabled(isLimitReached)
            
            // Send / Upgrade Button
            if isLimitReached {
                Button { showUpgrade = true } label: {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
            } else {
                Button { sendMessage() } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            canSend ? Color.blue : Color.secondary.opacity(0.3)
                        )
                        .clipShape(Circle())
                        .shadow(color: canSend ? .blue.opacity(0.3) : .clear, radius: 4, y: 2)
                }
                .disabled(!canSend)
                .scaleEffect(canSend ? 1.0 : 0.95)
                .animation(.spring(response: 0.3), value: canSend)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    private var responseSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "waveform")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                
                Text("SAGE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
                
                Spacer()
                
                // Clear button
                Button {
                    withAnimation {
                        clearResponse()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(Circle())
                }
            }
            
            // Content
            if chatState.isLoading && currentResponse.isEmpty {
                TypingIndicator()
                    .padding(.vertical, 4)
            } else {
                Text(currentResponse)
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(.primary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Action
            if !chatState.isLoading && !currentResponse.isEmpty {
                Button {
                    onSendToChat(currentResponse)
                    clearResponse()
                } label: {
                    HStack {
                        Text("Insert to Chat")
                            .fontWeight(.medium)
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
    
    private var limitReachedOverlay: some View {
        ZStack {
            Color.black.opacity(0.2).ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "lock.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
                    .shadow(color: .orange.opacity(0.3), radius: 10)
                
                VStack(spacing: 4) {
                    Text("Limit Reached")
                        .font(.headline)
                    Text("You've used your free messages for today.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 12) {
                    Button("Later") {
                         chatState.inputText = ""
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    Button {
                        showUpgrade = true
                    } label: {
                        Text("Unlock Unlimited")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(24)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Helpers
    
    private var isPremium: Bool { subService.isPremium }
    
    private var isLimitReached: Bool {
        !isPremium && usageService.isLimitReached
    }
    
    private var showLimitOverlay: Bool {
        isLimitReached && !chatState.inputText.isEmpty && !showUpgrade
    }
    
    private var shouldShowResponse: Bool {
        chatState.isLoading || !currentResponse.isEmpty
    }
    
    private var currentResponse: String {
        chatState.messages.last(where: { $0.role == .assistant })?.content ?? ""
    }
    
    private var canSend: Bool {
        !chatState.inputText.trimmingCharacters(in: .whitespaces).isEmpty && !chatState.isLoading
    }
    
    private func clearResponse() {
        chatState.messages.removeAll()
        chatState.isLoading = false
    }
    
    private func saveToHistory(prompt: String, response: String) {
        print("💾 Saving to history: \(prompt) -> \(response.prefix(20))...")
        let item = ChatHistoryItem(prompt: prompt, response: response)
        let context = DataController.shared.container.mainContext
        context.insert(item)
        do {
            try context.save()
            print("✅ Saved successfully!")
        } catch {
            print("❌ Failed to save history: \(error)")
        }
    }
    
    private func sendMessage() {
        let text = chatState.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !chatState.isLoading else { return }
        
        // Use a credit
        guard usageService.increment() else {
            showUpgrade = true
            return
        }
        
        chatState.messages.removeAll()
        chatState.messages.append(ChatMessage(role: .user, content: text))
        chatState.inputText = ""
        chatState.isLoading = true
        
        Task {
            do {
                let responseMessage = ChatMessage(role: .assistant, content: "")
                await MainActor.run { chatState.messages.append(responseMessage) }
                let responseIndex = await MainActor.run { chatState.messages.count - 1 }
                
                let stream = await openAI.streamMessage(text, context: nil, history: [], isPremium: isPremium)
                for try await chunk in stream {
                    await MainActor.run { chatState.messages[responseIndex].content += chunk }
                }
                
                
                await MainActor.run { chatState.isLoading = false }
                
                // Save to History
                let finalResponse = await MainActor.run { chatState.messages[responseIndex].content }
                if !finalResponse.isEmpty {
                   await MainActor.run {
                       saveToHistory(prompt: text, response: finalResponse)
                   }
                }
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

// MARK: - Micro Components

struct TypingIndicator: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(.secondary)
                    .offset(y: offset)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(0.1 * Double(index)),
                        value: offset
                    )
            }
        }
        .onAppear { offset = -4 } // Bounce up
    }
}

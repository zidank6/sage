import SwiftUI

/// Compact mode view: minimal input field with "Ask Sage" prompt
struct CompactView: View {
    @Bindable var chatState: ChatState
    let onRequestExpand: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // App icon
            Image(systemName: "message.badge.waveform.fill")
                .font(.title2)
                .foregroundStyle(.blue)
            
            // Input field
            TextField("Ask Sage anything...", text: $chatState.inputText)
                .textFieldStyle(.plain)
                .font(.body)
                .onSubmit {
                    if !chatState.inputText.isEmpty {
                        onRequestExpand()
                    }
                }
            
            // Expand button
            Button(action: onRequestExpand) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(chatState.inputText.isEmpty ? .gray : .blue)
            }
            .disabled(chatState.inputText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

#Preview {
    CompactView(
        chatState: ChatState(),
        onRequestExpand: {}
    )
}

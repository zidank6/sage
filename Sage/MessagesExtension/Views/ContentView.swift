import SwiftUI
import Messages

/// Root content view that switches between compact and expanded modes
struct ContentView: View {
    @Bindable var chatState: ChatState
    let presentationStyle: MSMessagesAppPresentationStyle
    let onSendToChat: (String) -> Void
    
    var body: some View {
        // Always use compact view - no expansion needed
        CompactView(
            chatState: chatState,
            onSendToChat: onSendToChat
        )
    }
}

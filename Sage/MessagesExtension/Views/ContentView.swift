import SwiftUI
import Messages

/// Root content view that switches between compact and expanded modes
struct ContentView: View {
    @Bindable var chatState: ChatState
    let presentationStyle: MSMessagesAppPresentationStyle
    let onRequestExpand: () -> Void
    let onSendToChat: (String) -> Void
    
    var body: some View {
        Group {
            switch presentationStyle {
            case .compact:
                CompactView(
                    chatState: chatState,
                    onRequestExpand: onRequestExpand
                )
            case .expanded:
                ExpandedView(
                    chatState: chatState,
                    onSendToChat: onSendToChat
                )
            case .transcript:
                // Transcript mode (inline in conversation)
                CompactView(
                    chatState: chatState,
                    onRequestExpand: onRequestExpand
                )
            @unknown default:
                CompactView(
                    chatState: chatState,
                    onRequestExpand: onRequestExpand
                )
            }
        }
    }
}

import UIKit
import Messages
import SwiftUI

/// Main view controller for the Sage iMessage extension.
/// Bridges MSMessagesAppViewController to SwiftUI - compact mode only.
class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Properties
    
    /// The SwiftUI hosting controller
    private var hostingController: UIHostingController<AnyView>?
    
    /// Shared state for the chat interface
    private let chatState = ChatState()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        let contentView = CompactView(
            chatState: chatState,
            onSendToChat: { [weak self] message in
                self?.insertMessage(message)
            }
        )
        
        let hostingController = UIHostingController(rootView: AnyView(contentView))
        self.hostingController = hostingController
        
        // Ensure visible background
        hostingController.view.backgroundColor = .systemBackground
        
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    // MARK: - Presentation Style
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        // Extract selected message text if available
        if let selectedMessage = conversation.selectedMessage,
           let layout = selectedMessage.layout as? MSMessageTemplateLayout {
            chatState.selectedContext = layout.caption ?? layout.subcaption
        }
    }
    
    /// Inserts a plain text message into the conversation
    private func insertMessage(_ text: String) {
        guard let conversation = activeConversation else { return }
        
        // Insert as plain text
        conversation.insertText(text) { [weak self] error in
            if let error = error {
                self?.chatState.errorMessage = "Failed to send: \(error.localizedDescription)"
            } else {
                self?.chatState.lastSentMessage = text
                // Clear the chat state after sending
                self?.chatState.messages.removeAll()
            }
        }
    }
}
